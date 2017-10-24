---
layout: post
title: "Building a Home Lab for Offensive Security"
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

**Pros:**

* Easy to spin up
* Takes no space
* No large initial investment (cost)

**Cons:**

* Ongoing cost
* Might be limited by ToS
* More difficult to manage
* Strange configurations are harder to build

### Hardware Option B: Decent Laptop ###

### Hardware Option C: Dedicated Hardware ###
