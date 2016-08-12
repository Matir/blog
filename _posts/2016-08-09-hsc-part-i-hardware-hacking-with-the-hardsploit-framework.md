---
layout: post
title: "HSC Part 1: Hardware Hacking with the Hardsploit Framework"
category: Security
date: 2016-08-09
tags:
  - Hacker Summer Camp
  - Black Hat
series: "Hacker Summer Camp 2016"
---

Just returned from Hacker Summer Camp (Black Hat, BSides LV, DEF CON) and I'm
exhausted.  10 days in Las Vegas is a *lot* of Las Vegas, even if you don't
spend a lot of time at the slot machines, table games, and shows.

My week started off with a training class at Black Hat: [Hardware Hacking with
the Hardsploit
Framework](https://www.blackhat.com/us-16/training/hardware-hacking-with-hardsploit-framework.html)
taught by a couple of guys who clearly knew their hardware.  I've previously
taken Xipiter's [Software Exploitation via Hardware
Exploitation](http://www.sexviahex.com/), which helped with some of the basic
concepts, but the two classes were definitely complimentary.  SexViaHex
predominantly focused on dumping firmware from embedded microcomputers (that is,
they had a kernel, typically Linux, and were running applications on them) and
analyzing them for exploitable software vulnerabilities (mostly memory
corruption-esque issues).  HH with Hardsploit, on the other hand, mostly focused
on microcontroller-based embedded devices.  This was much more a class of
dumping flash to locate stored secrets, understanding the hardware of the
device, and working from there.

![Hardsploit board connected to target](/img/blog/hsc2016/hardsploit.jpg)

I'm not going to list every thing taught in the class (I don't think the authors
would like that much) but I'll cover my highlights:

- Unlocking an electronic door lock (actually a dummy PCB to simulate an
  electronic door lock with keypad)
- Use GNURadio and an SDR to locate, identify, and receive an unknown wireless
  protocol.  We then had to write scripts to decode the received data and
  understand this wireless protocol.
- Use the techniques we learned before to do a drone CTF capstone consisting of trying to
  reverse engineer your drone, patch the flaws, and then exploit the flaws
  against other drones.  (Unfortunately, I feel there wasn't enough time left by
  this point, so we weren't able to get all the way through this exercise.)

This was only a two-day class, but I believe I learned a ton of new things and
got to exercise some skills I don't get to touch very often.  It was an intense
experience, and I'd rather think they could do so much more ina 4-day format.  I
would have no doubts about recommending this class to others, or to taking
another (more advanced) class from Opale.

As far as Black Hat Trainings are concerned: well, it includes breakfast and
lunch, which is nice, but the food is *literally* the worst food I had in Las
Vegas all week.  It was completely stereotypical hotel ballroom food: breakfast
was fruit platters and pastries with mediocre coffee and bottles of juice, and
lunch was a random assortment of "banquet quality" items (i.e., pasta that
wasn't drained properly so is now sitting in a puddle, salads that are swimming
in dressing, etc.).  There was also an afternoon coffee/tea service each day,
which was surprisingly nice (though swamped by attendees).  Having coffee all
day long for trainings would have helped my brain, but YMMV.

Next I'm off to BSides Las Vegas and Dichotomy's Pros versus Joe's CTF.
