---
layout: post
title: "BSides SF CTF Author Writeup: Flagsrv"
category: Security
date: 2019-03-08
tags:
  - CTF
  - BSidesSF
---

Flagsrv was a 300 point web challenge in this year's BSidesSF CTF.  The
description was a simple one:

> We've built a service for the sole purpose of serving up flags!
>
> The account you want is named 'flag'.

<!--more-->

## Background ##

This challenge was actually the result of a conversation with a coworker less
than 48 hours before the CTF.  We were discussing the different types of
multi-factor authentication and their merits, and the importance of strong
sources of entropy for many of these mechanisms.  I joked about a deterministic
method of generating keys, then decided to build a level around it.

## Exploring ##

So, what does the application do?  Well, when you first visited it, you were
given a fairly generic-looking login page, with an option to register that was
also pretty generic.

![Register Screen](/img/blog/bsidessf2019/flagsrv_register.png)

Okay, let's register an account and we get a page to store our flag.  Well,
great, but I want the flag from the user named `flag`, not whoever I just
register.  I already have my own flag, I want the one for the challenge!

You could try tampering with the session cookie to try to get a session for the
`flag` user, but I'm pretty sure I implemented it correctly.

There was an option to enable two factor authentication using the widely
supported [Time-based One Time
Passwords](https://en.wikipedia.org/wiki/Time-based_One-time_Password_algorithm)
(TOTP).  When this was done, a QR code compatible with many authentication
applications was displayed along with the raw Base32-encoded seed.

## Vulnerability/Exploitation ##

If you examine the 2FA registration page, you'll note that the secrets are
generated entirely in client-side javascript.  If you spend a bit of time doing
static analysis, or even just set a breakpoint on the `retrieveKey` function,
you'll notice the seed is entirely based on a single input:

```
  var retrieveKey = async function(u) {
    var buf = new ArrayBuffer(u.length);
    var v = new Uint8Array(buf);
    for (var i=0; i<u.length; i++) {
      v[i] = u.charCodeAt(i);
    }
    var k = await crypto.subtle.importKey(
      'raw',
      buf,
      {name: 'HMAC', hash: 'SHA-256', length: u.length*8},
      false,
      ['sign', 'verify']);
    var k2 = await crypto.subtle.sign(
      'HMAC',
      k,
      buf);
    return base32encode(k2);
  };
```

This function has the effect of performing `Base32(HMAC-SHA256(u, u))`, and it
turns out if you examine its callsite, the only parameter passed in the
username.  Given this, you can construct a secret for any username you'd like.

However, there's still no password for the `flag` user.  However, if we log in
with the user we registered and enabled 2FA for, we'll notice the following in
the 2FA verification page:

```
<input type="hidden" name="username" value="foo" />
<input type="number" id="passcode" min="0" max="999999"
    class="form-control" name="passcode" placeholder="000000">
```

It turns out that if we change the username in the hidden field and use the
correpsonding TOTP seed/value, it will log us in as that user, and not the user
from the first stage of the login!  Consequently, supplying `flag` as the value
for the hidden field along with a TOTP derived from the username-based HMAC key
will log in as the `flag` user and give access to the (read-only) game flag.
