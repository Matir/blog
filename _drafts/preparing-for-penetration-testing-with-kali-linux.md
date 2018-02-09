---
layout: post
title: "Preparing for Penetration Testing with Kali Linux"
category: Security
tags:
  - Security
  - PWK
  - OSCP
  - Education
excerpt:
  The Penetration Testing with Kali Linux course is one of the most popular
  information security courses, culminating in a hands-on exam for the Offensive
  Security Certified Professional certification.  It provides a hands-on
  learning experience for those looking to get into penetration testing or other
  areas of offensive security.  These are some of the things you might want to
  know before attempting the PWK class or the OSCP exam.
---

If you spend any time at all on Reddit or forums for information security
students, you'll find *dozens* of questions about preparing for the Penetration
Testing with Kali Linux (PWK, aka OSCP) class from Offensive Security.
Likewise, I've been asked by a number of people I know personally about moving
into the security realm.  I figured I'd put together some notes on how to
prepare and the knowledge that I believe is necessary to succeed with the PWK
class.

* TOC
{:toc}

## Basic Skills ##

### Note Taking ###

I know this seems completely unrelated, but trust me: to get the most out of
your PWK experience, you should be able to do an effective job of note taking.
Figure out how to structure your notes, how to keep data associated with
different machines, keeping screenshots with your notes, etc.

### Linux on the Workstation ###

It genuinely amazes me that people sign up for a class named "Penetration
Testing with Kali Linux" but have never used Linux before, yet there are many
reports of this on various forums.  Learn to use some form of Linux before
you're paying hundreds of dollars a month for lab access.  At a minimum you
should have familiarity with:

* The filesystem layout
* Network setup
* Shell familiarity
* How to use SSH

You don't have to use [Kali](https://www.kali.org/) (although it's not a bad
idea), but since it's based on Debian Testing, it makes sense to use some kind
of Debian derivative.  [Debian](https://debian.org),
[Ubuntu](https://www.ubuntu.com/), and [Mint](https://linuxmint.com/) are all
good options for this.

## Networking ##

### IP Networking ###

Almost all modern networks use IP at the Network Layer (L3).  Consequently, you
should be familiar with IP networking.  Mostly relevant is IP subnetting and the
difference between routing and switched networks.  Learn what RFC1918 is and why
those IP addresses are special.  It can be helpful to learn how to translate
between representations of CIDR subnets, such as `/24` and `/255.255.255.0`.

### TCP & UDP ###

You should know about the differences between TCP and UDP.  This includes the
differences in terms of connection establishment and maintenance, as well as the
reliability differences of the two protocols.  Knowing common port numbers of
well-known services will also be helpful.

### Network Protocols ###

Learn a little bit about some of the common protocols used on networks.  Even if
you don't learn details or read the RFCs, at least reading the Wikipedia article
on some of the most common protocols will be helpful.

* DNS
* Telnet
* SSH
* HTTP
* SMB

## Operating Systems ##

Knowing how operating systems function at a basic level will be very useful.
This includes the differences between operating systems, how processes work, how
the filesystems work, and certainly information about authentication &
authorization on each operating system.

### Linux ###

### Windows ###

## Security Topics ##

Obviously, PWK is mostly about learning security skills, but there should be
some fundamental knowledge that a student brings to the table.  Having an
understanding of security fundamentals will serve the student well during the
PWK course.

* The CIA Triad (Confidentiality, Integrity, and Availability)
* Authentication vs Authorization
* Memory Corruption Vulnerabilities
* Web Vulnerabilities (perhaps OWASP Top 10)

## Useful Resources ##

* [Red Team Field Manual](http://amzn.to/2nNHGNc) - Good for remembering quick
  commands and tool executions.
* [Kali Linux Revealed](http://amzn.to/2C5whgl) - Information about Kali Linux
  as a penetration testing distribution.
