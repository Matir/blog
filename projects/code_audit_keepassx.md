---
layout: project
title: "Code Audit: KeePassX"
date: 2010-11-01
---
This was my final project for my CS8803 class at Georgia Tech.  This was my first code audit, and was performed in the Fall of 2010, so may not apply to current versions.

**Summary**

KeePassX is a robust and feature-rich program that has thwarted my efforts to discover any
major weaknesses. When used on a single-user system, particularly with encrypted swap, it is highly
unlikely that any sensitive data will be leaked. The most likely way for a determined adversary to gain
access to a user's accounts will be through service weaknesses, predictable password reset options, or
the ever-popular $5 wrench. It's highly unlikely that KeePassX will be the source of a compromise without
malware on the user's workstation, and with continued development, that risk will be mitigated even further.

* [Code Audit: KeePassX](/static/attachments/keepassx.pdf)
