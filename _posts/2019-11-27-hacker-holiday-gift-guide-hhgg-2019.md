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
categorize things, but they tend to transcend boundaries somewhat.  Got a
suggestion I missed?  Hit me up on [Twitter](https://twitter.com/matir).

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

#### Breaking and Entering ####

[Breaking and Entering: The Extraordinary Story of a Hacker Called
"Alien"](https://amzn.to/2XXCzLy) is a mostly-true story about a professional
hacker (penetration tester), detailing her start while a student at MIT through
her career as a penetration tester.  It details not only some of the information
security-related hacks, but also other clever hacks and explorations in her
life.  It's an exciting read, and I was super happy to see how detailed and
accurate the recollection is.

#### Cult of the Dead Cow ####

[![Cult of the Dead Cow](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=154176238X&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US){:.right}](https://amzn.to/2Dwe3HD)

[Cult of the Dead Cow: How the Original Hacking Supergroup Might Just Save the World](https://amzn.to/2Dwe3HD)
is a great history of the early days of hacking and hacking groups.
cDc is probably the single most influential hacking group, and is responsible
for many of the tools that are used by information security professionals today.
With significant overlap with l0pht (another influential group), the group
helped to shape what hacking is today and has had significant influence that
many individuals may not realize.  Those outside the hacking scene may take many
things for granted that are influenced by cDc.  Whether you realize it or not,
they shaped the internet of today, and this is a well-researched read into their
history and influence.

## Electronics ##

#### Encrypted Flash Drive ####

[![DT2000](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B074QLHJR4&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US){:.left}](https://amzn.to/34u2ufY)

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

[![Keysy](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B07D7K2LCB&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US){:.right}](https://amzn.to/33r99X1)

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
* Multiple RFID modes supported.

#### Yubikey 5 ####

[![Yubikey 5](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B07HBD71HL&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US){:.left}](https://amzn.to/35HusoY)

The [Yubikey 5](https://amzn.to/35HusoY) is a hardware security token for a
variety of purposes.  Most obviously, it offers support for U2F/FIDO2/WebAuthn
for account login on sites like Google, GitHub, Dropbox, Coinbase, Lastpass, and
more.  This is a 2nd factor authentication mechanism that can't be phished or
attacked via mobile malware.

The Yubikey 5 also supports a smartcard mode where it can store OpenPGP and/or
SSH keys in its secure memory, protecting them against local malware attempts to
steal the keys.

#### Packet Squirrel ####

[![Packet Squirrel](/img/blog/gifts2019/packet_squirrel.jpg){:.right}](https://shop.hak5.org/products/packet-squirrel)

The [Hak5 Packet Squirrel](https://shop.hak5.org/products/packet-squirrel) is a
great little Man-in-the-Middle device.  With dual ethernet interfaces, it's a
physical MITM, so not vulnerable to the kinds of detection that work against ARP
spoofing and other techniques.  It's a great option for a penetration test drop
box, as well as things as simple as debugging network problems when you can't
run a packet capture on the endpoint itself.  It's USB micro powered and
supports pre-programmable payloads via an external switch, so you can have it
ready to perform any of several roles, depending on the situation you find
yourself in.  It runs a full Linux stack, so lots of capabilities available
there.

#### Shark Jack ####

[![Shark Jack](/img/blog/gifts2019/sharkjack.jpg){:.left}](https://shop.hak5.org/products/shark-jack)

The [Hak5 Shark Jack](https://shop.hak5.org/products/shark-jack) is a tiny
implant with a small battery built-in.  This battery allows it to be completely
self-contained, needing only an ethernet port to plug into.  This is perfect for
when you find that ethernet port behind a piece of furniture and can deploy your
implant quickly.  This isn't an implant to leave in place -- the battery only
lasts about 10-15 minutes.  (Though I suppose you could power it via USB-C, so
it's not impossible to run it that way.)  By default it will do a quick nmap
scan and save it to the internal flash, but you can, of course, script it to do
anything you want when plugged in.  Like the Packet Squirrel, theres a switch to
choose the mode you want to run.

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

#### Keyport Pivot ####

[![Keyport Pivot](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B06XC5SZKC&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US){:.right}](https://amzn.to/2rzzqFo)

More than just travel, the [Keyport Pivot](https://amzn.to/2rzzqFo) is part of
my every day carry.  I have a tendency to carry too much, and that includes
keys.  My keys feel so much more compact and so much more organized when in the
Keyport Pivot, which keeps them all together at once.  I also carry the [MOCA
Multi-tool](https://amzn.to/2L2lnyV) in my Pivot, which is a nice multi-tool
that meets TSA guidelines, so is great for those that travel regularly.  In
fact, the MOCA is also available in a [standalone
format](https://amzn.to/34wpNpz) with a handle and paracord pull.

## Tools/Maker ##

#### Raspberry Pi 4 ####

[![Raspberry Pi 4](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B07TC2BK1X&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US){:.right}](https://www.amazon.com/Raspberry-Model-2019-Quad-Bluetooth/dp/B07TC2BK1X/ref=as_li_ss_il?crid=UBATM8CI8LKG&keywords=raspberry+pi+4&qid=1574968305&s=electronics&sprefix=ras,electronics,202&sr=1-4&linkCode=li2&tag=systemovecom-20&linkId=66110bc97f08113b78b1d848eff78c41&language=en_US)

The [Raspberry Pi 4](https://amzn.to/2XT9X63) is the latest generation of the
venerable Raspberry Pi single board computer.  This generation has entered the
realm of being a full desktop for web surfing, etc., as well as an option for a
home theater PC or emulating older console game titles.  It even has enough
processing power to pair with the [Analog Discovery 2](https://amzn.to/2qKexaJ)
to be a PC-based oscilloscope/logic analyzer.  They've finally upgraded to
Gigabit ethernet, so much better on the network (though it retains built-in WiFi
support as well).

#### Circuit Playground Express ####

[![Circuit Playground Express](/img/blog/gifts2019/cpe.jpg){:.right}](https://www.adafruit.com/product/3333)

Adafruit's [Circuit Playground Express](https://www.adafruit.com/product/3333)
is the ultimate introduction to embedded devices.  Programmable in either the
popular Arduino IDE or CircuitPython, this takes the concept of an Arduino one
step further.  Instead of having to hook up lights, buttons, or sensors, they
are all integrated into the one board.  It includes two push buttons, an
accelerometer, 10 RGB LEDs, temperature, light and sound sensors, and much more.
It's powered by an ARM microcontoller at 48 MHz to allow you to make use of all
these inputs and outputs, and can be extended via the connections around the
outside (which are large enough to use with alligator clips).  If you or someone
you know wants to learn embedded development without needing to do wiring or
circuits themselves, this is a great way to get started.

#### iFixit Tool Kit ####

[![iFixit Toolkit](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B01GF0KV6G&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US){:.left}](https://amzn.to/2qL4FNU)

This [iFixit Tool Kit](https://amzn.to/2qL4FNU) is my go-to toolkit for opening
and working with electronics.  It has all the bits I've found on devices,
including the "security Torx" bits, precision Phillips and slotted bits, and hex
bits.  The handle is a great size to both get a grip but also fit into tight
spaces, and the flex shaft helps in even tighter spaces.  The plastic spudgers
and pry tool are great for getting into devices held together with clips instead
of (or in addition to) screws.  (Like the base plate on my Lenovo laptop, and so
many electronic devices.)  I've used some of the cheaper clones of these kits,
and the pieces just don't hold up as well as these do, or are made with
materials that don't perform as well.

#### Pocket Flashlight ####

[![Microstream](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B077BLB1DN&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US){:.right}](https://amzn.to/34EK3Wl)

This [USB-rechargable pocket flashlight](https://amzn.to/34EK3Wl) is a very
useful tool to have on hand.  Flashlights are obviously useful, but being
rechargable is both eco-friendly and convenient, and being pocket-sized ensures
you can always have it with you.  (Or carry it in your bag instead of your
pocket, which is my approach so I don't lose it.)  Streamlight is a well known
brand with strong ratings and a history of quality, so this will keep going
reliably.

#### Sugru ####

[Sugru](https://amzn.to/2DoPInd) is a "Mouldable Glue", which is basically an
adhesive putty that holds fast when it cures.  They are useful for making custom
hooks, adding protection or strain relief to cables, waterproofing around
openings, or repairing small breaks.  As it's silicone based, it remains
slightly flexible and holds up well against water.  I've used it before to seal
around cables going through openings in enclosures and to make custom cable
organizers.

#### Skeletool CX ####

[![Skeletool](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B0043NYPA6&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US){:.left}](https://amzn.to/2smfLZT)

Like the pocket flashlight, I like to carry a multitool with me daily.  I've
carried the [Skeletool](https://amzn.to/2smfLZT) for a few years now, including
a replacement after I accidentally got to the TSA checkpoint with one.  (Oops.)
This has a knife blade, pliers, and the ability to hold interchangable bits in
the handle for a screwdriver.  I've run into many occassions where this was
useful, ranging from quick repairs to taking something apart on a whim, to
opening packages.  There's even a bottle opener at the base of the handle, which
is perfect for those adult beverages.  (No corkscrew for you wine drinkers.  Try
screwtop bottles.)
