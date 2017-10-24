---
layout: post
title: "Building a Home Lab for Offensive Security & Security Research"
category: Security
tags:
  - Home Lab
  - Lab
  - Security
  - Education
  - Training
---

When I wrote my ["getting started" post](/2017/09/18/getting-started-in-offensive-security.html)
on offensive security, I promised I'd write about building a lab you can use to
practice your skillset.  It's taken a little while for me to get to it, but I'm
finally trying to deliver.

Much like the post on getting started, I'm not claiming to have all the answers.
I'll again be focusing on an environment that helps you build a focus in the
areas I most work in -- penetration testing, black box application security,
and red teaming.  (And if you're wondering about the difference between a
penetration test and red team, there will be a post for that too -- I promise
they're very different.)

As usual, I encourage others to share their thoughts with me via
[Twitter](https://twitter.com/Matir) or email.

* Table of Contents
{:toc}

## Use Cases ##

There's a few different things you might want to do with your lab.  I'll list
some of the more common things I do with my lab setups below, because how you
use it will influence how you set it up.

### Full Environment Simulation ###

This is probably the most complex option, but also one of the most useful,
especially if you're just getting into penetration testing.  In this case, you
want to build out a full replica of a target environment, but entirely owned and
controlled by you (so it's legal to play around in).

If you're looking to practice for a particular engagement/environment, you'll
want to reproduce your target environment as closely as possible.  If you want a
general lab to practice pentesting, you can simulate a fairly typical corporate
environment.

### Application Security Research ###

When doing application security research, your goals are quite a bit different
from pentesting.  In application security, you generally want to be able to
instrument the application as much as you can.  Most critically, you want to be
able to intercept all of the network traffic to/from the application, attach a
debugger to the application, and otherwise control the environment.  Ideally,
you also want to keep the miscellaneous noise to a minimum, so using a system
with nothing else going on can be helpful.

Depending on the application, you might want a web proxy like Burp Suite, or
a packet capture tool like Wireshark.  In either case, you can either run your
proxy locally or use a router to direct traffic through.

For mobile application testing, you can use an emulator, or you might want a
cheap access point on your lab network to which you can connect a real device.

### Tool Testing ###

Tool testing will have all kinds of different requirements depending on what
tool you want to test.  It's hard to give more advice than to think about the
environment the tool is designed to test/exploit/assess.

## Hardware ##

There's a number of options for where to run your lab environment, and they all
have pros and cons, and in reality, you're likely to eventually use some
combination of them.  I'll give a quick rundown of the options and pros/cons of
each below.  There's no single right or wrong answer, because it will depend on
a variety of factors:

- Your budget
- What you already have
- How extensive you want your lab to be
- The specific skills you want to work on
- Space available/spousal approval

### Hardware Option A: Just Use the Cloud ###

Obviously, we're moving into a "Cloud" world (for better or for worse).
Consequently, it's not surprising that a lab in the cloud might be a popular
choice, but it comes with a *lot* of tradeoffs.

Unless you know what you want
to do fits the cloud model well, or you absolutely don't have a better option,
beginners might find one of the other options better suited to their needs.

For most of the tasks I've described, you'll want to choose a provider that
allows you to have a private virtual network between hosts, so that your traffic
is segregated from other customers.  You'll also need to carefully read the
terms of service to ensure anything you do is within bounds -- just because
you're testing against your own VMs doesn't mean you can do anything you want on
somebody else's infrastructure.

You'll also want to be sure to figure out what kind of connectivity you can get
into your lab for the types of attacks you want to perform.  Some attacks
require that you have a host on the same network (not routed) as your target, so
you'll either need an L2 VPN (e.g., OpenVPN in a bridged configuration) or
you'll need to set up a box in your lab dedicated to being the 'attacker'
machine.

Operating System choice is also key -- if you want to practice on Windows
domains, a Cloud provider that's only selling Linux VPS won't do you a lot of
good.  Even those that offer Windows might not offer Windows client systems, but
that's not terrible -- you can often treat a Windows Server as a client anyway,
it will just take some extra configuration.

For a lot of my testing, I use [DigitalOcean](https://m.do.co/c/b2cffefc9c81),
but they're a Linux-only environment, so better for Application testing than for
full environment simulation.

**Pros:**

* Easy to spin up
* Takes no space
* No large initial investment (cost)

**Cons:**

* Ongoing cost
* Might be limited by ToS
* More difficult to manage
* Strange configurations are harder to build

### Hardware Option B: Decent Laptop/Desktop ###

So, "decent" is subjective, but there are a few guidelines here:

- You need support for hardware virtualization.  (Intel VT)  Consequently, some
  Celeron-, Atom- and Pentium-branded processors won't make the cut, as well as
  some of the AMD A-series.  Any Core i3, i5, or i7 should do the trick.
- Memory is critical.  VMs love memory.  Count on *at least* 2GB for a Windows
  Client, 4GB for a Windows Server, and 1GB for a minimal Linux install, but
  more is always better.  I look for at least 16GB of RAM in a laptop if I'm
  going to be running a lot of VMs.
- The hard drive requirements aren't massive, but you'll want more than
  something like a 128GB SSD.  I use a [1TB Samsung 850 EVO](http://amzn.to/2lbSSEw),
  but that might be a bit overkill for most users.

There are obviously a lot of laptops that meet the minimums you'd want, so the
rest is about making sure you're comfortable using it.  A good screen and a good
keyboard are key in that.  These days, you really shouldn't settle for 720p
screens (1368x768), so 1920x1080 (1080p) is about your starting point there.

**Pros:**

* Cheapest, if you already have one usuable
* Portable (laptop)

**Cons:**

* Can be quite expensive
* Least flexible option
* Might not support enough VMs for some configurations

### Hardware Option C: Dedicated Hardware ###

This is the most serious, but also the most flexible option.  Having a lab on
dedicated hardware will cost, but it allows you to build out whatever you want.

There's a few approaches here.  Simplest is basically a standard desktop build,
but instead of running a full desktop OS on it, you can run ESXi, Xen, Proxmox,
or another Hypervisor build.  More complex, you can have a
[NAS](http://amzn.to/2yLfH6P) and use something like an [Intel
NUC](http://amzn.to/2gGtCFf) or other small form factor
[PC](http://amzn.to/2yJwlSO) to provide your compute power.

Most people will opt for either a desktop or the small form factor options, but
others can spare the space (and cost) of a small home rack with a larger NAS and
a few rack-mounted servers.  Of course, you can really go to an extreme: check out
[/r/homelab](https://www.reddit.com/r/homelab) to see what some people have done
(though not necessarily for a security-focused homelab).

**Pros:**

* Most Flexible
* Most Powerful

**Cons:**

* Potentially very expensive
* Can consume lots of power/space

## Software

I'll be describing a generic software setup, but you might need to adjust based
on how you've setup the hardware/hosting for your lab environment.

### Networking

I suggest placing your machines on an isolated network.  There's several
different ways you can do this:

- Private networking provided by your cloud provider (obviously only for a lab
  in the cloud)
- A virtual network in your virtualization software
- A separate physical network switch (only usuable if your hardware is dedicated
  to your lab)
- A VLAN on a managed network switch

Whichever way you choose will keep your "normal" traffic apart from your lab
traffic, and prevent you from causing trouble for anyone else who might use your
network (spouses, roommates, significant others, guests, etc.).

I like to put a router between the two networks to give internet access to your
lab (obviously be careful that anything malicious stays within the lab) and to
provide remote access (via OpenVPN).  I currently use pfSense to provide this,
which you can run on bare metal, or run as a Virtual Machine.

### Operating Systems

My lab setup has varied over time, but I'd say the "common ground" of a lab is
something that replicates your typical enterprise environment.  At a minimum,
this will include:

- Windows Servers (typically a Domain Controller)
- Linux Servers (typically Application Servers)

### Applications

### Security Software

## My Personal Setup

My personal setup is not necessarily the right way to do things (in fact, I have
a *lot* I'd like to change) but I include it as an example for others of how a
lab setup can be used in practice.

### Hardware

My main lab setup is a desktop build with:

- [AMD FX-8300](http://amzn.to/2yKZ2jD) CPU
- [Asus M5A78L-M](http://amzn.to/2yK2RnH) Motherboard
- 16 GB DDR3
- 2x [HGST Deskstar NAS 4TB](http://amzn.to/2yJxtFL) Drives

This all connects to a [ZyXEL GS1900-16](http://amzn.to/2yMhqHD) managed switch
so I can have separate VLANs for lab and regular network access.  Possibly
overkill, but it works well for me and was a great opportunity to learn about
VLANs, trunking, 802.1q, etc.

I've also added a couple of Raspberry Pis and some other hardware over time for
specific cases.  I keep a previous-generation cell phone for research in the lab
as well.  (Because I'd rather not install sketchy apps on my regular phone.)

None of this is particularly high end hardware, and it's only a few hundred
dollars worth of hardware.  I've also accumulated it over several years, so this
is an example of how you can start simple and grow from there.  For example, I
used to use old 500GB-1TB hard drives, and the network switch is also a
relatively recent addition.

### OS/Software
