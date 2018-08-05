---
layout: post
title: "I'm the One Who Doesn't Knock: Unlocking Doors From the Network"
category: Security
date: 2018-08-10
tags:
  - IoT
  - Security
series: Hacker Summer Camp 2018
attachment: unlocking_doors.pdf
---

![IoT Hacker](/img/blog/iot_hacker.png){:.right}

Today I'm giving a talk in the [IoT Village](https://www.iotvillage.org) at DEF
CON 26.  Though not a "main stage" talk, this is my first opportunity to speak
at DEF CON.  I'm really excited, especially with how much I enjoy IoT hacking.
My talk was inspired by the research that lead to
[CVE-2017-17704](/2017/12/18/cve-2017-17704-broken-cryptography-in-istar-ultra-ip-acm-by-software-house.html),
but it's not meant to be a vendor-shaming session.  It's meant to be a
discussion of the difficulty of getting physical access control systems that
have IP communications features right.  It's meant to show that the designs we
use to build a secure system when you have a classic user interface don't work
the same way in the IoT world.

(If you're at DEF CON, come check it out at 4:45PM on Friday, August 10 in the
IoT Village.)

<!--more-->

The TL;DR of it is that encryption (particularly with a key hardcoded in the
device firmware) does not guarantee authenticity and that an attacker can forge
messages triggering behavior on the door access controller.  What's more
interesting is to discuss how to fix this problem in product designs going
forward.

Getting encryption right is hard at the best of times.  Doing it in a way that
allows reasonable management of the devices, with proper authentication of
connection, when you have devices that may not have hostnames (or if they do,
may be internal only hostnames), that don't have classic user interfaces, that
may fail and need to be replaced, is very hard.

It's also worth noting that the amount we should care about security really does
depend on the product involved.  While I don't deny that an RCE in a light bulb
could become part of a botnet, authentication bypass in an access control system
is pretty scary.  It literally has *one job*: to deny unauthorized access.
Having the ability to bypass it over the network is clearly impactful.

I hope my talk will inspire conversations about how to do network trust among
networks of embedded & IoT devices.  As security professionals, we haven't
offered the device developers the tools to bootstrap the trust relationships in
the real world.  Here's to hoping that next year, I can be discussing a
different type of bug.

## Slides ##

{% include slides.html %}
