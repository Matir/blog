---
layout: post
title: "Matir's Favorite Things"
category: Personal
tags:
  - Security
  - Hardware
  - Tools
kramdown: true
date: 2016-08-20
---

One of my friends was recently asking me about some of the tools I use,
particularly for security assessments.  While I can't give out all of these
things for free Oprah-style, I did want to take a moment to share some of
my favorite security- and technology-related tools, services and resources.

## Hardware

[![Lenovo T450s](/img/blog/favorite_things/t450s.jpg){:.left}](http://shop.lenovo.com/us/en/laptops/thinkpad/t-series/t450s/)
My primary laptop is a **Lenovo T450s**.  For me, it's the perfect mix of weight and
processing power -- configured with enough RAM, the i5-5200U has no trouble
running 2 or 3 VMs at the same time, and with an internal 3-cell battery plus a
6-cell battery pack, it will go all day without an outlet.  (Though not
necessarily under 100% CPU load.)  Though Lenovo no longer sells this, having
replaced it with the T460s, it's still [available on
Amazon](https://amzn.to/2boky1C).

[![Startech](/img/blog/favorite_things/startech_gige.jpg){:.right}](https://amzn.to/2bJjYxj)
[The **StarTech.com USB 3.0 dual gigabit ethernet interface**](https://amzn.to/2bJjYxj)
allows one to perform ethernet bridging or routing across it, while
still having the built-in interface to connect to the internet.  If you don't
have a built-in interface, it still gives you two interfaces to play with.  Each
interface is an [ASIX AX88179](http://www.asix.com.tw/products.php?op=pItemdetail&PItemID=131;71;112)
chip, and you'll also see a `VIA Labs, Inc. Hub` appear when you connect it,
giving some idea of how the device is implemented: a USB 3.0 hub, plus two USB
3.0 to GigE PHY chips.  I haven't benchmarked the interface (maybe I will soon)
but for the cases I've used it for -- mostly a passive MITM to observe traffic
on embedded devices -- it's been much more than sufficient.

[![WiFi Pineapple Nano](/img/blog/favorite_things/pineapple_nano.jpg){:.left}](https://hakshop.myshopify.com/products/wifi-pineapple?variant=81044992)
The [**WiFi Pineapple Nano**](https://hakshop.myshopify.com/products/wifi-pineapple?variant=81044992)
is probably best known for its Karma trickery to impersonate other wireless
networks, but this dual radio device is so much more.  You can use it to connect
one radio to a network and the other to share out WiFi, so you only have to pay
for one connected device.  In fact, you can put OpenVPN on it when doing this,
so all your traffic (even on devices that don't support a VPN, like a Kindle) is
encrypted across the network.  (Use WPA2 with a good passphrase on the client side if you want to have
some semblance of privacy there.)

[![LAN Turtle](/img/blog/favorite_things/lan_turtle.png){:.right}](https://hakshop.myshopify.com/products/lan-turtle?variant=3862428037)
The [**LAN Turtle**](https://hakshop.myshopify.com/products/lan-turtle?variant=3862428037)
is essentially a miniature ARM computer with two network interfaces.  One of
those interfaces is connected to a USB-to-Ethernet adapter, resulting in the
entire device looking like an oversized USB-to-Ethernet adapter.  You can plug
this inline to a computer via USB and have an active MITM on the network, all
powered from the USB port it's plugged into.  This is a stealthy drop box for
access on an assessment.  (I haven't tried, but I imagine you can power it from
a wall-wart and just plug in the wired interface if all if you need is a single
network connection.)  My biggest complaint about this device is that it, like
all of the Hak5 hardware, is really not that open.  I haven't been able to build
my own firmware for it, which I'd like to do, rather than just using the
packages available in the default LAN Turtle firmware.

[![ALFA WiFi Adapter](/img/blog/favorite_things/alfa.jpg){:.left}](https://amzn.to/2bAYVK4)
The [**ALFA AWUS036NH**](https://amzn.to/2bAYVK4) WiFi Adapter is the
802.11b/g/n version of the popular ALFA WiFi radios.  It can go up to 2000 mW,
but the legal limit in the USA is 1000 mW (30 dBm), and even at that power,
you're driving further than you can hear with most antennas.  I like this
package because it comes with a high-gain 7 dBi panel antenna and a suction cup
mount, allowing you to place the adapter in the optimal position.  Just in case
that's not enough, you can get a [13 dBi yagi](http://amzn.to/2bAYIXn) to extend
both your transmit and receive range even further.  Great for demonstrating that
a client can't depend on physical distance to protect their wireless network.

## Books

Oh man, I could go on for a while on books... I'm going to try to focus on just
the highlights.

![Stealing the Network](/img/blog/favorite_things/stealing_network.jpg){:.right}
There's a number of books containing collections of anecdotes and stories that
help to develop an **attacker mindset**, where you begin to think and understand
as attackers do, preparing you to see things in a different light:

* [Stealing the Network](http://amzn.to/2b6QQew)
* [The Art of Deception](http://amzn.to/2b7FgAx)
* [The Art of Intrusion](http://amzn.to/2bpvqKU)
* [Dissecting the Hack](http://amzn.to/2b6RE3b)
* [Geek Mafia](http://amzn.to/2butlAm) (and [Geek Mafia: Mile
  Zero](http://amzn.to/2b6RDfO) and [Geek Mafia: Black Hat
  Blues](http://amzn.to/2b6UC7C))

![RTFM](/img/blog/favorite_things/rtfm.jpg){:.left}
For Assessments, Penetration Testing, and other Offensive Security practices,
there's a huge variety of resources.  While books do tend to become outdated
quickly in this industry, the fundamentals don't change that often, and it's
important to understand the fundamentals before moving on to the more advanced
topics of discussion.  While I strongly prefer eBooks (they're lighter, go with
me everywhere, and can be searched easily), one of my coworkers swears by the
printed material -- take your pick and do whatever works for you.

* [Red Team Field Manual: RTFM](http://amzn.to/2b6SWv4) -- A quick reference to
  commands and techniques across a variety of platforms.
* [The Web Application Hacker's Handbook](http://amzn.to/2buuqs2) -- The
  definitive guide to web application assessment.
* [Hacking: The Art of Exploitation](http://amzn.to/2b7DC4A) -- A great
  introduction to memory corruption vulnerabilities.
* [Metasploit: The Penetration Tester's Guide](http://amzn.to/2bB2DUa) -- The
  best written material I've seen for using Metasploit on a Penetration Test.

I'm not much of a blue teamer, so I'm hard pressed to suggest the "must have"
books for that side of the house.

## Services

I have to start with [**DigitalOcean**](https://m.do.co/c/b2cffefc9c81).  Not
only is this blog hosted on one of their VPS, but I do a lot of my testing and
research on their VPSs.  Whenever I need a quick VM, I can spin one up there for
under 1 cent per hour.  I've had nearly perfect uptime (my own stupidity
outweighs their outages at least 10 to 1) and on the rare occasion I've needed
their support, it's been absolutely first rate.  DigitalOcean started off for
developers, but they offer a great production-quality product for almost any
use.
