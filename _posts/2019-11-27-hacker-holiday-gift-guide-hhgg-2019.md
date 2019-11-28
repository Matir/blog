---
layout: post
title: "Hacker Holiday Gift Guide (HHGG) 2019"
category: Security
date: 2019-11-27
tags:
  - Hacker Holiday Gift Guide
---

I wanted to put together a few thoughts I had on gifts for my fellow hackers
this holiday season.  I'm including a variety of different things to appeal to
almost anyone involved in information security or hardware hacking, but I'm
obviously a bit biased to my own areas of interest.  I've tried to roughly
categorize things, but they tend to transcend boundaries somewhat.

<!--more-->

* Categories
{:toc}

## Books ##

#### Quick Reference Manuals (RTFM, BTFM, HashCrack) ####

[![RTFM](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=1494295504&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US){:.right}](https://amzn.to/2L0jrHn)

Though some have questioned the usefulness of having this material in printed
form, I sometimes like being able to thumb through these for a quick reference.
The 3 quick references I've used a bunch of times are:

* [The Red Team Field Manual (RTFM)](https://amzn.to/2L0jrHn)
* [The Blue Team Field Manual (BTFM)](https://amzn.to/35HmvjE)
* [Hash Crack: Password Cracking Manual](https://amzn.to/2ONdOgK)

Each of these are quick translations of information for cases where you might
not be familiar with the relevant information immediately, such as needed to run
shell commands on a platform that is less familiar to you, or esoteric
post-exploitation information at the last minute.  Though internet through a
cell phone makes it less critical, having this when onsite can be a quick win,
and if you ever need to test or assess when in an area with no reception, it's
even more benefit.

## Electronics ##

#### Encrypted Flash Drive ####

[![DT2000](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B074QLHJR4&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US)](https://amzn.to/34u2ufY)

This [encrypted flash drive](https://amzn.to/34u2ufY) has hardware-based
encryption to protect the data contained on it.  Because the security is
hardware based, it's workable with any operating system or hardware platform.
It's also immune to hardware keylogging.  It uses a PIN pad to support
input of the passcode, and the operating system can't interact with the drive at
all until it is locked.  The downside of hardware encryption is that it is very
hard to verify or audit, but I believe the quality of this particular flash
drive to be relatively high.  Though these drives are expensive for the
capacity, they're not all about dollars per gigabyte -- the features are in the
firmware.  It's available at least up to [64GB](https://amzn.to/2QUBRgt).

#### Keysy RFID Duplicator ####

[![Keysy](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B07D7K2LCB&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US)](https://amzn.to/33r99X1)

The [Keysy RFID duplicator](https://amzn.to/33r99X1) lets you clone various
forms of RFID credentials either into its internal memory, or into a writable
card.  Though it's dead simple to use, it's not as flexible or sophisticated as
an RFID hacking tool like the Proxmark.  It's super useful for cloning things
like apartment gate fobs or basic proxcard authentication systems for access
control.  It won't work for anything using encryption or handshaking.  It also
only works on low-frequency (125 kHz) RFID technology, which tends to be the
unencrypted cards anyway.

#### Proxmark3 RDV4 ####

[![Proxmark3](/img/blog/gifts2019/proxmark3.jpg){:.right}](https://hackerwarehouse.com/product/proxmark3-rdv4-kit/)

The [Proxmark3 RDV4](https://hackerwarehouse.com/product/proxmark3-rdv4-kit/) is
an RFID hacking kit.  Unlike the Keysy, this is for those interested in more
advanced RFID hacking, including cracking encrypted RFID cards, or researching
custom RFID implementations.  This supports both 125 kHz and 13.56 MHz RFID
cards, and due to the customizable firmware, it can be adapted to run just about
any protocol known.  There are even some offline modes that don't require a
connection to a computer to hack the RFID cards (such as automatic cloning or
replay).

* Can pretend to be either a card or reader.
* Sniff communications between other readers & cards.
* Operate standalone
* Multiple modes supported.

#### Yubikey 5 ####

[![Yubikey 5](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B07HBD71HL&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US)](https://amzn.to/35HusoY)

The [Yubikey 5](https://amzn.to/35HusoY) is a hardware security token for a
variety of purposes.  Most obviously, it offers support for U2F/FIDO2/WebAuthn
for account login on sites like Google, GitHub, Dropbox, Coinbase, Lastpass, and
more.  This is a 2nd factor authentication mechanism that can't be phished or
attacked via mobile malware.

The Yubikey 5 also supports a smartcard mode where it can store OpenPGP and/or
SSH keys in its secure memory, protecting them against local malware attempts to
steal the keys.

## Travel ##

#### Anker 60W Dual USB-PD Charger ####

[![Anker USB-PD Power Supply](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B07DFGXLY4&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US){:.right}](https://amzn.to/33sPLcn)

Anker is one of my favorite manufacturers of chargers, USB battery banks, etc.
I've had very good experiences with their products, and [this 60W USB-PD charger
with 2 USB-C ports](https://amzn.to/33sPLcn) is one of the most compact and
capable USB-PD chargers I've found.  It can charge two phones or laptops at the
same time, or -- best of all -- one of each, which makes it great for travel
(laptop + phone).  Using Gallium Nitride (GaN) instead of Silicon transistors
makes it smaller and more efficient than other models of USB power supplies.

#### Anker USB-PD Battery Pack ####

[![Anker USB-PD Battery](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B01MZ61PRW&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US){:.right}](https://amzn.to/2pWPPTU)

Like their USB-PD chargers, I'm super happy with Anker battery packs.  My main
travel USB power supply is a smaller and older version of [this battery pack](https://amzn.to/2pWPPTU), but
I have no doubt this one is also a great option.  This battery is 26800mAh,
which is about 99Wh, so just *barely* under the FAA 100 Wh limit for lithium ion
batteries -- in other words, this is the largest possible battery bank you can
bring on an airplane in the US.  It's about 7 full charges of a cell phone, or a
complete recharge of your USB-C powered laptop.

#### Travel Router ####

[![AR750S](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B07GBXMBQF&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US){:.left}](https://amzn.to/37TIh5E)

It's amazing how useful a travel router is on the road.  My current favorite is
the [AR-750S (Slate)](https://amzn.to/37TIh5E) from GL.iNet.  The stock firmware
is based on [OpenWRT](https://openwrt.org/), which means you can do a wide
variety of things by installing a stock OpenWRT build and then using the wide
OpenWRT ecosystem of packages to enhance your router.  Alternatively, you can
build your own custom OpenWRT build with whatever features and configuration
you'd like, using OpenWRT's buildroot system.  The router has a lot of hardware
features, including both a core NOR flash and an expanded NAND flash.

Some of the reasons for using a travel router include:

* Single connection for multiple devices when you're limited to a single
  connection (e.g., hotels)
* VPN connection for all connected devices.
* Drop device for penetration testing engagements.
* Local network for client-to-client comms (e.g.,
  [Chromecast](https://store.google.com/us/product/chromecast))

There are also cheaper options like the [GL-MT300N](https://amzn.to/2rwyEcf) or
the [GL-AR300M](https://amzn.to/2OTbTHs) if you don't need all the power of the
Slate.

## Tools/Maker ##

## Stocking Stuffers ##
