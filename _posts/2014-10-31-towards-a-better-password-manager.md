---
layout: post
title: "Towards a Better Password Manager"
date: 2014-10-31 01:16:10 +0000
permalink: /2014/10/31/towards-a-better-password-manager/
category: Security
tags:
  - Security
  - Passwords
redirect_from:
  - /blog/towards-a-better-password-manager/
---
The consensus in the security community is that [passwords suck](http://www.wired.com/2014/08/passwords_microsoft/), but they're here to stay, at least for a while longer.  Given breaches like [Adobe](http://krebsonsecurity.com/2013/10/adobe-breach-impacted-at-least-38-million-users/), ..., it's becoming more and more evident that the biggest threat is not weak passwords, but [password reuse](https://xkcd.com/792/).  Of course, the solution to password to reuse is to use one password for every site that requires you to log in.  The problem is that your average user has [dozens of online accounts](http://www.dailymail.co.uk/sciencetech/article-2174274/No-wonder-hackers-easy-Most-26-different-online-accounts--passwords.html), and they probably can't remember those dozens of passwords.  So, we build tools to help people remember passwords, mostly password managers, but do we build them well?

I don't think so.  But before I look at the password managers that are out there, it's important to define the criteria that a good password manager would meet.

1. **Use well-understood encryption to protect the data.** A good password manager should use cryptographic constructions that are well understood and reviewed.  Ideally, it would build upon existing cryptographic libraries or full cryptosystems.  This includes the KDF (Key-derivation function) as well as encryption of the data itself.  Oh, and all of the data should be encrypted, not just the passwords.

1. **The source should be auditable.**  No binaries, no compressed/minified Javascript.  If built in a compiled language, it should have source available with verifiable builds.  If built in an interpreted language, the source should be unobfuscated and readable.  Not everyone will audit their password manager, but it should be possible.

1. **The file format should be open.** The data should be stored in an open, documented, format, allowing for interoperability.  Your passwords should not be tired into a particular manager, whether that's because the developer of that manager abandoned it, or because it's not supported on a particular platform, or because you like a blue background instead of grey.

1. **It should integrate with the browser.**  Yes, there are some concerns about exposing the password manager within the browser, but it's more important that this be highly usable.  That includes making it easy to generate passwords, easy to fill passwords, and most importantly: harder to phish.  In-browser password managers can compare the origin of the page you're on to the data stored, so users are less likely to enter their password in the wrong page.  With a separate password manager, users generally copy/paste their passwords into a login page, which relies on the user to ensure they're putting their password into the right site.

1. **Sync, if offered, should be independent to encryption.**  Your encryption passphrase should not be used for sync.  In fact, your encryption passphrase should *never* be sent to the provider: not at signup, not at login, not ever.  Sync, unfortunately, sounds simple: drop a file in Dropbox or Google Drive, right?  What happens if the file gets updated while the password manager is open?  How do changes get synced if two clients are open?

These are just the five most important features as I see them, and not a comprehensive design document for password managers.  I've yet to find a manager that meets all of these criteria, but I'm hoping we're moving in this direction.
