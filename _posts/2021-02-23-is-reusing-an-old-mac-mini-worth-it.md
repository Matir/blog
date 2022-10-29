---
layout: post
title: "Is Reusing an Old Mac Mini Worth It?"
category: Computers
date: 2021-02-23
tags:
  - Hardware
---

I was cleaning up some old electronics (I'm a bit of a pack rat) and came across
a Mac Mini I've owned since 2009.  I was curious whether it still worked and
whether it could get useful work done.  This turned out to be more than a 5
minute experiment, so I thought I'd write it up here as it was just an
interesting little test.

<!--more-->

## The Hardware

The particular model I have is known as "Macmini2,1" or "MB139\*/A" or "Mid
2007", with the following specs:

* Intel Core 2 Duo T7200 at 2.0 GHz
* 2 GB DDR2 SDRAM (originally 1GB, I upgraded)
* 120GB HDD

## The Software

The last version of Mac OS that was supported is Mac OS X 10.7 "Lion", which has
been unsupported since 2014.  Since I'm a Linux guy anyway, I figured I'd see
about installing Linux on this.  Unfortunately, according to the [Debian
wiki](https://wiki.debian.org/MacMiniIntel), this device won't boot from USB,
and I don't have any blank optical media to burn to.  This was the first point
where I nearly decided this wasn't worth my time, but I decided to push on.

Linux is pretty good about booting on any hardware, even if it's not the
hardware you installed on, as kernel module drivers are loaded based on present
hardware.  I decided to try installing to a disk and then swapping disks and
seeing if the Mac Mini would boot.  The EFI on the Mac Mini supports BIOS
emulation, and that seemed the more likely to work out of the box.

I plugged a [spare SSD](https://amzn.to/3dEZapP) into my [SATA
dock](https://amzn.to/37IR1Nv) and then used a virtual machine with a raw disk
to install Debian testing on the SSD.  I then used the [excellent iFixIt
teardown](https://www.ifixit.com/Device/Mac_Mini_Model_A1176) and my [iFixit
toolkit](https://amzn.to/3bseqnm) to open the Mac Mini and swap out the drive.
I point to the teardown because opening a Mac Mini is neither obvious nor
trivial.

## Booting

I plugged in the Mac Mini along with a network cable and powered it on, hoping to
see it just appear on the network.  I gave it adequate time to boot and did a
port scan to find it -- and got nothing.  Thinking it might have been a first
boot issue, I rebooted the Mac Mini, waited even longer, and checked again --
and once again, couldn't find it.  I checked the logs on my DHCP server, and
there was nothing relevant there.  This is the second point at which I
considered quitting on this.

I decided to see what error I might have been getting, or at least how far it
would get in booting, so I dug out a DVI cable and hooked it up to a monitor.
Powering it on again, I got 30 seconds of grey screen from the EFI (due to the
BIOS boot delay mentioned in the Debian wiki page), and then -- Debian booted
normally.

Okay, maybe networking was just broken.  I did another port scan of my lab
network -- and there it was.  Somehow it had just started working.  I felt so
confused at this point.  I began to wonder if connecting a monitor had been the
fix somehow.  A few Google searches later, I had confirmed my suspicion -- this
Mac Mini model (and several others) will not boot unless it detects an attached
monitor.  There's a workaround involving a resistor between two of the analog
pins (or a commercial [DVI emulator](https://amzn.to/3qOyC9s)), but for the
moment, I just kept the monitor attached.

At this point, I had the Mac Mini running Debian Testing and everything seemed
to be more or less working.  But would it be worth it in terms of computing
power and electrical power?

## Benchmarking & Comparison

I decided to run just a handful of CPU benchmarks.  I wasn't looking to tweak
this system to find the maximal performance, just to get an idea of where it
stands as a system.

The first run was a 7-zip benchmark.  The Mac Mini managed about 3700 MB/s for
compression.  (Average across all dictionary sizes.)  My laptop with a Core
i5-5200U did 6345MB/s, and my [Ryzen 7 3700X](https://amzn.to/3bDV8f0) in my
desktop managed a whopping 57,250MB/s!

With OpenSSL, I checked both SHA-512 and AES-128-CBC mode.  For SHA-512
computations, the Mac Mini managed about 200 MB/s, my laptop 470 MB/s, and my
desktop 903 MB/s.  For AES-128-CBC, the Mac Mini is 89MB/s, my laptop 594MB/s,
and my desktop a whopping 1.6GB/s!  This result is obviously heavily skewed by
the AES-NI instructions present on my laptop and desktop, but not the Mac Mini.
(These are all single-thread results.)

Finally, I ran the POV-Ray 3.7 benchmark.  The Mac Mini took 952s, my laptop
452s, and my desktop just 54s.

I began to wonder how all these results compared to something like a Raspberry
Pi, so I pulled out a [Pi 3B+](https://amzn.to/3bxa8uP) and a [Pi
4B](https://amzn.to/2ZH3Ovt) and ran the same benchmarks again.

| Device             | 7-Zip      | SHA-512    | AES-128   | POV-Ray 3.7 |
|--------------------|------------|------------|-----------|-------------|
| Mac Mini w/T7200   | 3713 MB/s  | 193 MB/s   | 89 MB/s   | 952s        |
| Laptop (i5-5200U)  | 6345 MB/s  | 470 MB/s   | 593 MB/s  | 452s        |
| Desktop (R7-3700X) | 57250 MB/s | 903 MB/s   | 1591 MB/s | 54s         |
| Raspberry Pi 3B+   | 1962 MB/s  | 31 MB/s    | 47 MB/s   | 1897s       |
| Raspberry Pi 4B    | 3582 MB/s  | 204 MB/s   | 91 MB/s   | 597s        |

As can be seen, in most of the tests, the Mac Mini with a Core 2 Duo is trading
blows back and forth with the Raspberry Pi 4B -- and gets handily beat in the
POV-Ray 3.7 test.  Below is a chart of normalized test results, with the slowest
device a 1.0 (always the Pi 3B+), and all others represent how many times faster
the other systems are.

![Normalized Relative Performance](/img/macmini/chart.png)

During all of these tests, I had the Mac Mini plugged into a
[Kill-A-Watt Meter](https://amzn.to/3dEoi03) to measure the power consumption.
Idling, it's around 20 watts.  Under one of these load tests, it reaches about
45-49 watts.  Given that the Raspberry Pi 4B only uses around 5W under full
load, the Pi 4B absolutely destroys this Mac Mini in performance-per-watt.
(Note, again, this is an *old* Mac Mini -- it's no surprise that it's not an
even comparison.)

## Conclusion

Given the lack of expandability, the mediocre baseline performance, and the very
poor performance per watt, I can't see using this for much, if anything.
Running it 24/7 for a home server doesn't offer much over a Raspberry Pi 4B, and
the I/O is only slightly better.  At this point, it's probably headed for the
electronics recycling center.
