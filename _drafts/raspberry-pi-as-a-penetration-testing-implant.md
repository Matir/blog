---
layout: post
title: "Raspberry Pi as a Penetration Testing Implant (Dropbox)"
category: Security
tags:
  - Penetration Testing
  - Red Team
description:
  Build a penetration testing dropbox using a Raspberry Pi
---

[![Raspberry Pi 4](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B07TC2BK1X&Format=_SL250_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US){:.left .amzimg}](https://www.amazon.com/Raspberry-Model-2019-Quad-Bluetooth/dp/B07TC2BK1X/ref=as_li_ss_il?cv_ct_cx=raspberry+pi&dchild=1&keywords=raspberry+pi&pd_rd_i=B07TC2BK1X&pd_rd_r=cf3c4a78-81c5-4c9a-921f-9c70bae2796e&pd_rd_w=XB1nE&pd_rd_wg=PG6Eq&pf_rd_p=1da5beeb-8f71-435c-b5c5-3279a6171294&pf_rd_r=6XKT1T3E2254DKNEXTAY&psc=1&qid=1594437202&sr=1-1-70f7c15d-07d8-466a-b325-4be35d7258cc&linkCode=li3&tag=systemovecom-20&linkId=cf0fb5b6f95cfb61bff474270a0b5ea1&language=en_US)

Sometimes, especially in the time of COVID-19, you can't go onsite for a
penetration test.  Or maybe you can only get in briefly on a physical test, and
want to leave behind a dropbox (literally, a box that can be "dropped" in place
and let the tester leave, no relation to the file-sharing company by the same
name) that you can remotely connect to.  Of course, it could also be part of the
desired test itself if incident response testing is in-scope -- can they find
your malicious device?

In all of these cases, one great option is a small single-board computer, the
best known of which is the [Raspberry Pi](https://amzn.to/3fl8jSn).  It's
inexpensive, compact, easy to come by, and very flexible.  It may not be perfect
in every case, but it gets the job done in a lot of cases.

I'll use this opportunity to discuss the setups I've done in the past and the
things I would change when doing it again or alternatives I considered.  I hope
some will find this useful.  Some familiarity with the Linux command line is
assumed.

<!--more-->

## Table of Contents
{:.no_toc}

* TOC
{:toc}

## General Principles of Dropboxes

As mentioned above, a dropbox is a device that you can connect to the target
network and leave behind.  (In an authorized test, you'd likely get your
hardware back at the end, but it's always possible that someone
steals/destroys/etc. your device.)  This serves as your foothold into the target
network.

For some penetration tests, you'll be able to provide your contact the dropbox
and have them connect it to the network.  This can allow you to have an
internally scoped test but not require your physical presence at their site.
This can be useful to avoid travel costs (or, currently, avoid COVID-19).  In
this case, you'll have an agreed-upon network segment that it will be connected
to.  (Commonly, this will be a network segment with workstations as opposed to a
privileged segment.)

If you're going physical and want to leave a dropbox behind, you'll have to be
more opportunistic about things.  You'll get whatever network segment you get,
so you might want to consider dropping a couple of devices if the opportunity
presents itself.

In all these cases, you'll need to remotely control the dropbox over some
network connection, and then operate it to perform your attacks.

## Connecting Back

You'll almost always want your dropbox to initiate an outbound connection for
remote control.  You'll almost always be behind NAT or a firewall on the target
network, and dynamic IP addressing would likely make it hard to find your
implant anyway.  There's two different major approaches: "in band", where your
command and control (C2) traffic goes out via the target network you're
connected to, and "out of band" where your C2 is via a separate dedicated
connection.

### In Band

The easiest approach is to go with an "in band" C2 connection.  In this case,
you tunnel your traffic out on the same physical connection as you've connected
to your target network.  This is very straightforward when the right conditions
exist, since you just need power and the one network connection.  Unfortunately,
those right conditions are several:

- No Network Access Control, or NAC that allows access to the internet
- Some form of unfettered outbound connection
- DHCP IP Assignment on the segment

If any of these fails, you just have a little box connected to a cable that
doesn't let you do anything.  There are also some *risks* associated with in
band connections:

- Connection might be noticed/detected by Intrusion Detection Systems (IDS)
- Any DNS, etc., traffic would be visible

Despite the risks and requirements, this will work in a large majority of use
cases, and it's both cheap and simple to setup, which makes it both desirable
and the approach I've taken nearly every time I've setup a Pi-based dropbox.

### Out of Band

For an out of band connection, you need to bring your own network connection to
the dropbox.  Generally, I've done that with a WiFi based connection, but
another popular option is to go with a cellular connection.  WiFi is easier to
setup, but obviously has range limitations, while a cellular connection will
*usually* get you better range.

For WiFi, you can act as a client and connect to a guest or open network from
your target, or perhaps a network of an adjacent office.  Alternatively, you
could run an AP mode, but then you need to stay in a relatively close range to
be able to connect to your dropbox.  (The AP mode really only works if you're
able to put it near a window or you can stay nearby, say in a shared office
space.)

[![USB Cellular Dongle](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B07XXBQPZL&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US){:.left .amzimg}](https://www.amazon.com/ZTE-MF833V-Customized-Version-Covering/dp/B07XXBQPZL/ref=as_li_ss_il?dchild=1&keywords=cellular+dongle&qid=1594436300&sr=8-4&linkCode=li2&tag=systemovecom-20&linkId=a7668cc52205a17e12f51fdf9e825298&language=en_US)

For a cellular connection, the most popular option is a USB dongle that you
insert a SIM card into.  The nicer dongles will act like an ethernet network interface
(typically via [RNDIS](https://en.wikipedia.org/wiki/RNDIS)) to give you a
minimum amount of configuration, and generally will work out of the box with
Linux, whereas other dongles may be a little harder to get working.  I've used
the [ZTE MF833V](https://amzn.to/38LEyI0) with success in the past.

### Tunnel Software

Regardless of how you connect back, you probably need some kind of tunneling
software for the connection.  (The exception being the case where you setup an
AP on the Pi and connect directly to it.)

Pretty much all of these require a server as some kind of "meeting point" where
both the dropbox(es) and the operator(s) connect.  This gives the dropboxes a
static IP or hostname to connect to that's online all the time, and allows
operator(s) behind NAT/firewalls to connect in.  I use
[DigitalOcean](https://m.do.co/c/b2cffefc9c81) to host servers for projects (as
well as this blog -- and if you use my link, you'll get $100 in free credit for
new users as well as support articles like this), but you can of course use any
server or VPS that you have.

My favorite approach is actually using `ssh` to establish an outbound connection
that forwards a port back to the dropbox for its own SSH server.  I realize this
sounds confusing, so I hope this diagram helps:

<!--TODO diagram for post-->

Unfortunately, this may result in multiple layers of TCP, so throughput will be
sub-optimal, but it works well, and I can run an SSH server on Port 443, which
is effective for any network that allows HTTPS out without SSL interception.
(Almost nobody, it turns out, does any kind of inspection to confirm that
443/tcp traffic is actually TLS.)

I recommend using a tool like [`autossh`](https://www.harding.motd.ca/autossh/)
to manage your SSH connection in case the connection drops.  You'll also want to
enable keepalives to both ensure the connection stays up longer, and also to
enable `autossh` to more easily detect a loss of connectivity.

The other alternative I can recommend is to use a VPN.  Previously, I would have
used OpenVPN, but I have become a [WireGuard](https://www.wireguard.com/)
convert, especially for lower powered devices like the Raspberry Pi.  (The
crypto used by WireGuard can sustain higher throughput on low-end devices.)  The
biggest downside to this is you'll need to run UDP out, so it can be a little
harder if you're going with the "in band" approach on a restrictive network.

## Setup & Challenges

One of the keys is to have your dropbox ready to go when you deploy it.
Depending on your approach, someone else might be deploying it (if a remote
engagement, or if someone else is doing your physical testing), you might not
have much time, or there might be other constraints.  In any case, you want to
make sure it's ready to go when you are.

Among other things, this means having the tools you'll want already set up (you
don't want to waste time and bandwidth installing new tools once the dropbox is
in place), having your connection(s) set up, and having contingency plans in
case something goes wrong.

### Resiliency

### Software

### Confidentiality/Data Protection

Like everything else you do as a penetration tester or red teamer, it's
important to protect your client's data.  Whatever you choose to use for your
control connection should be encrypted, but it's also a good idea to encrypt any
sensitive data that's at rest on the dropbox in case someone locates it and
takes it (and feels like examining the contents of the SD card).

One obvious option is to encrypt everything, such as with full-disk encryption,
but since you won't be able to unlock the device on boot, this isn't as easy an
option.  There are ways to remotely unlock with an SSH server in an `initramfs`,
but that adds complexity and risk of failures.

Instead, having a dedicated data partition that's encrypted is a good tradeoff
that will still offer protection for the data in the case the SD card is
examined.  I like to use LUKS for this -- it's easy enough to setup and
well-studied for the use case.  Unfortunately, Broadcom didn't license the ARM
crypto extensions, so performance is not great, but XTS mode is a couple of
times faster than `CBC` mode, so make sure you use that.

```
% cryptsetup benchmark
#     Algorithm |       Key |      Encryption |      Decryption
        aes-cbc        128b        23.8 MiB/s        77.6 MiB/s
        aes-cbc        256b        17.2 MiB/s        58.9 MiB/s
        aes-xts        256b        85.0 MiB/s        75.1 MiB/s
        aes-xts        512b        65.4 MiB/s        57.4 MiB/s
```

(Benchmarks taken from a Raspberry Pi 4B with 4GB of RAM.) {:.caption}

### Network Access Control

## Other Options

### Dedicated Devices

### Alternative Single-Board Computers

## Related Work
