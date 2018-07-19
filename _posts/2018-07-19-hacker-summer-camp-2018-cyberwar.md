---
layout: post
title: "Hacker Summer Camp 2018: Cyberwar?"
category: Security
date: 2018-07-19
series: Hacker Summer Camp 2018
tags:
    - DEF CON
    - Hacker Summer Camp
---
I actually thought I was done with the pre-con portion of my Hacker Summer Camp
blog post series, but it turns out that people wanted to know more about "[the
most dangerous network in the
world](https://www.computerworld.com/article/2974662/network-security/wi-fi-at-def-con-dealing-with-the-worlds-most-dangerous-network.html)".
Specifically, I got questions about how to protect yourself in this hostile
environment, like whether people should bring a burner device, how to avoid
getting hacked, what to do after the con, etc.

## The Network ##

So, is it "the most dangerous network in the world"?  Well, there's probably
some truth to that in the sense that in terms of *density* of threats, it's
likely fairly high.  In terms of sheer volume of threats, the open internet is
obviously going to be a leader.

First off, the DEF CON network is really multiple networks.  There's the open
WiFi, which is undeniably the Wild West of computers, and there's the DEF CON
"secure" network, which uses WPA2-Enterprise (802.1x) with certificates to
verify the APs.  The secure network also features client isolation.
Additionally, the secure network is monitored by a dedicated NOC/SOC with some
very talented and hard-working individuals.  I would assert that being
compromised on the secure network is approximately the same risk as being
compromised on any internet connection.

So, there's 0-day flying around left and right?  Not so much.  Most of the
malicious traffic is likely coming from someone who just learned how to use
Metasploit or just found out about some cool tool in a talk or workshop.
Consequently, it's unlikely to have much impact for those who patch and are
security-aware.

What you will see a *ton* of is WiFi pineapples.  People will go buy one at the
Hak5 booth, and then immediately turn it on and try to mess with other
attendees.  It gets pretty old, pretty quickly.  Just make sure you're connected
to the DEF CON Secure WiFi and this will be a minimal problem (maybe a denial of
service).

In all honesty, the con hotel WiFi is a worse place to be than DEF CON secure,
by a large margin.  Plenty of stupid things happening there.

## 3 Approaches ##

### The Minimalist ###

The minimalist carries a flip phone with a burner SIM.  He/she maintains contact
with friends using SMS or (*gasp*) actual phone calls.  No laptop, no smart
phone to be compromised.  This is a great approach if you're not going to
participate in any activities that require tech on hand.  If you're going to
hang out, listen to a few talks, and drink, this is the approach with no need to
worry about getting compromised.

### The Burner ###

No, this isn't about Burning Man, although DEF CON is *kinda* like Burning Man
for "400-lb hackers in basements".  This hacker brings a burner version of
everything: so a smart phone, but a cheap burner.  This probably *will* get
compromised, as their carrier hasn't pushed a patch in 3 years.  (And even
before that, it shipped with some shady pre-installed apps that send all your
contacts over plaintext to a server in China...).  They also bring a [$200
Dell](https://amzn.to/2NYnW50) or HP laptop with Kali Linux on board.

They connect to the first WiFi they see, never mind that it's labeled "FBI
Surveillance Van 404".  If you plan for your hardware to get pwned, it doesn't
really matter if it's bad WiFi, right?

Of course, in order for this to work correctly, you have to never use your
devices for anything sensitive.  Hopefully the urge to check your real email
doesn't get too strong.  Or maybe your card is suspended for potentially
fraudulent activity (like that $300 SDR) and you decide to log in "briefly" to
reactivate it.  This route really only works if you can maintain good OpSec.

### "Good Enough" Security ###

If you can set aside ego and assume nobody is willing to try using a $100k+
O-day on you, you can get by with a reasonable level of security.  This involves
bringing a modern fully-patched phone (iPhone or "flagship" Android phone), and
optionally a well-secured laptop.

For the laptop, I've previously discussed using a Chromebook.  Even with dev
mode for [crouton](https://github.com/dnschneid/crouton), I believe this to be
reasonably safe from remote exploitation.  This can also be cheap enough to be a
disposable device.  In my previous post, I suggested 3 Chromebook options:

* Budget: [Acer Chromebook 11](https://amzn.to/2uFQY0l) ($203)
* Mid-Range: [Asus C302CA](https://amzn.to/2utbphX) ($449)
* Top Shelf: [Pixelbook](https://amzn.to/2usuz7q) ($911)

Alternatively, you can get a cheap laptop and run fully-updated Windows 10 or
Linux with a firewall enabled and be in a pretty good state for passive attacks
over the network.

In either case, you should then run a VPN.  I like [Private Internet
Access](https://www.privateinternetaccess.com/pages/buy-vpn/), but there's a lot
of options out there, or you can even run your own OpenVPN server if you're
feeling adventurous.

## Summary ##

There's never a guarantee of security, but with updated devices & good security
hygiene, you can survive the DEF CON networks.  The basic elements involved are:

* Fully updated OS
* Be super careful
* Use a VPN
* No Services Exposed

Good luck and see you at Hacker Summer Camp!
