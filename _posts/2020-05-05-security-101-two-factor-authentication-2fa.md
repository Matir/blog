---
layout: post
title: "Security 101: Two Factor Authentication (2FA)"
category: Security
date: 2020-05-05
tags:
  - Security 101
---

In this part of my "Security 101" series, I want to talk about different
mechanisms for two factor authentication (2FA) as well as why we need it in the
first place.  Most of my considerations will be for the web and web
applications, and I'm explicitly ignoring local login (e.g., device unlock)
because the threat model is so different.

<!--more-->

* Table of Contents
{:toc}

## Why Two Factor At All

Username and password alone has proven itself inadequate time and time again.
[Have I Been Pwned](https://haveibeenpwned.com/) reports 443 breached sites with
more than 9 billion account credentials dumped.  Users have a tendency to use
predictable passwords, reuse passwords across sites, enter their credentials
into phishing sites, and otherwise have poor habits with passwords.  Two factor
authentication helps with most of these concerns to varying degrees.

### Potential Threats Against Passwords

**Phishing** is when a user inputs their username and password into a
malicious website that has been setup to capture credentials for a service.
Often this uses a clone of the legitimate website's appearance, and may redirect
the user to the legitimate login page after their submission (making users
believe the first attempt failed and trying again).  An attacker can then take
the captured credentials and log into the users account.

**Password reuse** is when a user uses the same username and password on
multiple sites.  When one site is compromised, the username and password become
available.  Often, an attacker will use **credential stuffing** to then attempt
to use these leaked credential lists on other sites to compromise accounts.

**Keylogging** is when the user enters their password into a computer or
keyboard that logs keystrokes, exposing their specific credentials to an
attacker.  There is a broader variety of **malware** on the host machine (doing
more than keylogging) that can capture clipboard input, HTML form fields, etc.

**Weak passwords** are a common problem for some users -- using passwords based
on names, dates of birth, or even just common passwords like "password123" or
"zxcvbn".  These are *relatively* unlikely online attacks as most services will
rate-limit or block the attacker trying a large number of passwords for a single
user, but not all services will do this.  In an enterprise, you can often find
ancillary services that use the active directory/LDAP infrastructure for
authentication but do not trigger failed login counter increments nor block
login attempts.

### Attacks on Two Factor Mechanisms

Once users started using two factors, attackers started attacking it.  I'll
broadly discuss some of the threats two factor implementations face before
getting into the implementations themselves.

**Phishing** remains a problem.  Yes, it turns out that if you can convince
someone to type in their username and password, you can also likely convince
them to type in some form of second factor.  Any form of two factor that
requires the user to type in some input is at risk from phishing.

**Malware** on the user's computer will get just about every form of
authentication.  Even if the two factor is protected in some way, an attacker
can just steal the cookies or other session tokens to impersonate the user,
inject javascript into the DOM of running sites, or tunnel traffic through the
user's computer ("man in the browser").  There's very little that will save the
day when you're working on a pwned computer.

There are other attacks on specific mechanisms that I'll discuss below.

## Two Factor Mechanisms

Traditionally, factors have been grouped into categories, specifically:

- Something you know (passwords)
- Something you have (tokens, phone, device, etc.)
- Something you are (biometrics)

Having "two factor" authentication meant having two of the 3 categories above.
I'll discuss how closely each of the 2FA mechanisms matches the taxonomy
systems.  I'm not aware of any implementations of biometrics for client/server
use, so none of those come into play.

### Security Questions are **NOT** Two Factor

Some web applications seem to treat security questions as a second factor.
Firstly, these fit clearly in the "something you know" category (along with
passwords), so you don't have a second factor from that perspective.  Even if
you believe that a second set of information would help, if people are answering
the questions correctly, these are almostly certainly going to be shared among
multiple sites.  If that wasn't damning enough, a lot of these questions ask
information that's publicly available, making targeted attacks quite trivial.
Please, please, don't use security questions.

### SMS (Text Message) Codes

So many sites have support for SMS-based two factor authentication.  When you go
to login, the site texts you a one time code that is valid for a limited
lifetime, then you enter the code into the site to provide the second factor.

In theory, this is a "something you have" mechanism for validating that you have
your cell phone.  In practice, this is validating that someone has access to
your phone number, whether that's through an SMS to web gateway or other
mechanisms.  It's very much vulnerable to phishing attacks, and there have been
documented cases of [individuals being social
engineered](https://www.forbes.com/sites/zakdoffman/2020/01/25/whatsapp-users-beware-this-stupidly-simple-new-hack-puts-you-at-riskheres-what-you-do/#27e672b61d76)
to give up an SMS code by forwarding it to someone else.

In addition to these concerns, SMS messages are not encrypted end-to-end,
meaning the cell carriers and governments may have access to it.  While
government access to the 2FA code might not be a concern in some countries,
authoritarian regimes likely have used these to access private accounts.
Additionally, the SS7 system used by mobile carriers to coordinate traffic is
known to be insecure, and this weakness has been [used to steal
money](https://www.cyberscoop.com/finally-happened-criminals-exploit-ss7-vulnerabilities-prompting-concerns-2fa/)
even from accounts supposedly protected by two factor.  Finally, attackers have
been known to perform [SIM
Swapping](https://en.wikipedia.org/wiki/SIM_swap_scam) where they convince your
mobile carrier to port your number to their phone, so they begin receiving your
SMS codes.  NIST [stopped
recommending](https://www.schneier.com/blog/archives/2016/08/nist_is_no_long.html)
SMS-based two factor authentication in 2016 because of these issues.

### Time Based Codes (e.g., Google Authenticator[^authenticator])

This is a fairly common approach to two factor and most in the security world
have seen it at least once.  You set it up using a mobile app where you scan a
QR code, and then you get a new code every 30 seconds.  When you want to login,
you input this code from your app.  Most often, this is an implementation of
Time-Based One Time Passwords (TOTP) as specified in
[RFC 6238](https://tools.ietf.org/html/rfc6238).  This uses a hash of the
current time and a seed that was provided by the site via the QR code.  Both
sides have the same seed value and so can compute the same OTP code.

Common implementations include:

- [Google Authenticator](https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2&hl=en_US)
- [AndOTP](https://play.google.com/store/apps/details?id=org.shadowice.flocke.andotp&hl=en_US)
- [Authy](https://play.google.com/store/apps/details?id=com.authy.authy&hl=en_US)

Unfortunately, like all other factors requiring the user to input a value into
the website by hand, this is a phishable mechanism.  Additionally, malware on
the mobile device, such as
[Cerberus](https://www.zdnet.com/article/android-malware-can-steal-google-authenticator-2fa-codes/),
is now known to steal codes directly from the authenticator apps.

### Mobile App Confirmation (Out of Band Confirmation)

A few services have implemented a mechanism using their mobile applications to
validate new sign-ins.  These are tricky because you need to already be signed
in on mobile, but basically they'll just prompt on your mobile device to confirm
that it's you signing in.

Unlike SMS-based 2FA, this is usually carried over TLS, so not vulnerable to
those attacks.  Likewise, because the user input is just an acknowledgement, the
credential itself cannot be phished, however users can still be social
engineered into acknowledging it, especially if the attacker is proxying
credentials to the legitimate service immediately from their phishing page.

### Physical Token (e.g., RSA SecurID[^securid])

These were quite popular for a while, and still seem to be in some heavily
regulated (i.e., slow to change) industries.  For these, you have a dedicated
hardware token that displays a periodically-changing code on a screen (some may
have a code that changes with the press of a button instead).  Some
implementations may just be hardware implementations of TOTP or the related
Hash-Based One Time Passwords (HOTP), but there are proprietary implementations,
such as RSA's.

These usually keep the seed for the 2nd factor with the manufacturer, which can
lead to problems, as in the [2011 breach of
RSA](https://www.theregister.co.uk/2011/04/04/rsa_hack_howdunnit/) that gave
access to the seeds for its tokens.  An attacker could then impersonate these
tokens even without physical posession.

Once again, because of the user input step, we're vulnerable to phishing as
well.

### Universal 2nd Factor/Web Authentication (U2F/FIDO/WebAuthn)

Web Authentication (WebAuthn), formerly known as Universal 2nd Factor (U2F), and
developed by the FIDO Alliance (yeah, it's had a few names) is a mechanism that
uses a cryptographic signature to prove the authenticity of a device.  U2F
specifically is just a second factor to be used with a username and password,
but WebAuthn even allows for the token to be the only authentication mechanism.

This is often implemented by a physical token, such as the [YubiKey
5](https://amzn.to/2SK3ZD3)[^yubikey] or the Open-Source Hardware
[Solo](https://amzn.to/2WaE8X2).  These store the secret key for the
U2F/WebAuthn keypair in a hardware security element or a microcontroller on
board.  In either case, remotely extracting (e.g., via malware on the device)
the two factor key is not possible.  They also require a "user presence" test
(e.g., tapping the device or pushing a button).

It can also be implemented on a phone by storing the key in a secure element or
using ARM TrustZone, or (for example) using the fingerprint reader in the Apple
touchbar.  These depend on the security of the device to protect the keys
involved.

In all cases, this is not vulnerable to phishing -- the user is not inputting
anything, and in fact, the origin of the site they're logging into is part of
the challenge and response flow.  The flip side is that it does require support
from the applications involved -- for example, your browser must have support
for WebAuthn to authenticate to the site.  The browser speaks to the
hardware/software token on your behalf, and attests to the origin being
authenticated and a "key handle" that ensures that each site only gets back its
own data.

There's a lot more to it, but U2F/FIDO have come up with a very strong mechanism
for two factor authentication.  Properly implemented, it's resistant to device
cloning, phishing, and even active MITM.  (Note that an active MITM in your TLS
session can still steal your session cookies, but still won't be able to
impersonate you for future login attempts.)

## Comparison Table


| Mechanism | Credential Stuffing | Phishing | Cloning |
|+++++++++++|+++++++++++++++++++++|++++++++++|+++++++++|
| SMS Codes |
| Out of Band |
| TOTP App |
| Physical Token |
| U2F/WebAuthn |


## Conclusion

I hope you find this overview of two factor mechanisms useful.  If you want to
dive into much more detail about authentication systems, then [NIST
SP800-63-3](https://pages.nist.gov/800-63-3/sp800-63b.html) is worth a read,
though I'd grab a coffee, Red Bull, or Club Mate first.  As always, please [let
me know](https://twitter.com/matir) if you have any feedback.

(Also, notice how many times I had to mention something being vulnerable to
phishing -- gotta love that humans are the perpetually unpatchable
vulnerability.)

[^authenticator]: Google Authenticator is a Trademark of Google LLC.
[^securid]: SecurID is a Trademark of RSA Security LLC.
[^yubikey]: YubiKey is a Trademark of Yubico, Inc.
