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
first place.

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
