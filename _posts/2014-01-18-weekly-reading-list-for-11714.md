---
layout: post
title: "Weekly Reading List for 1/18/14"
date: 2014-01-18 05:00:00 +0000
permalink: /blog/weekly-reading-list-for-11714/
category: Security
tags: reverse engineering,Security,CTF,SDR,Hacking
---
I've decided to start posting a weekly reading list of interesting security-related articles I've come across in the past week.  They're not guaranteed to be new, but should at least still be relevant.

#### Using a BeagleBone to bypass 802.1x
Most security practitioners are already aware that NAC doesn't provide meaningful security.  While it'll keep some random guy from plugging in to an exposed ethernet port in the lobby (shouldn't that be turned off?), it won't stop a determined attacker.  You can just MITM the legitimate device, let it perform the 802.1x handshake, then send packets appearing to be from the legitimate device.  To make it easier, [ShellSherpa has put together a BeagleBone-based device to automatically MITM the NAC connection](http://shellsherpa.nl/nac-bypass-8021x-or-beagle-in-the-middle).

#### Screwing with microcontroller devices
Matasano and Square have announced a joint [microcontroller-based CTF](http://www.matasano.com/matasano-square-microcontroller-ctf/).

#### Which SDR to buy?
SDR continues to be a hot button topic, and Taylor Killian has a post from a couple of months ago to help you choose what SDR device you should get: [HackRF vs. bladeRF vs. USRP](http://www.taylorkillian.com/2013/08/sdr-showdown-hackrf-vs-bladerf-vs-usrp.html).  While you'll need to understand basic radio concepts to get much out of the comparison, you should probably be at least at that level before you start doing much with SDR.

#### New disassembly framework
[Capstone](http://www.capstone-engine.org/) is a project to create a framework for disassembling binaries from a wide variety of architectures.  Doesn't seem to have binary extraction yet, so you'll need to get the text segment yourself and rebase it, but I'm hopeful it'll make its way into some interesting projects.

#### Dead Tree Reading
Although I'm mostly reading eBook formats, wanted to highlight which books I'm reading lately.

- [Reversing: Secrets of Reverse Engineering](http://www.amazon.com/gp/product/0764574817/ref=as_li_ss_tl?ie=UTF8&camp=1789&creative=390957&creativeASIN=0764574817&linkCode=as2&tag=systemovecom-20) by Eldad Eilam
- [The Web Application Hacker's Handbook](http://www.amazon.com/gp/product/1118026470/ref=as_li_ss_tl?ie=UTF8&camp=1789&creative=390957&creativeASIN=1118026470&linkCode=as2&tag=systemovecom-20) by Dafydd Studdard and Marcus Pinto

