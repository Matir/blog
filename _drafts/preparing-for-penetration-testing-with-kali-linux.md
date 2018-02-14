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
  The Penetration Testing with Kali Linux (PWK) course is one of the most
  popular information security courses, culminating in a hands-on exam for the
  Offensive Security Certified Professional certification.  It provides a
  hands-on learning experience for those looking to get into penetration testing
  or other areas of offensive security.  These are some of the things you might
  want to know before attempting the PWK class or the OSCP exam.
---

If you spend any time at all on Reddit or forums for information security
students, you'll find *dozens* of questions about preparing for the [Penetration
Testing with Kali
Linux](https://www.offensive-security.com/information-security-training/penetration-testing-training-kali-linux/) (PWK, aka OSCP) class from Offensive Security.
Likewise, I've been asked by a number of people I know personally about moving
into the security realm.  I figured I'd put together some notes on how to
prepare and the knowledge that I believe is necessary to succeed with the PWK
class.  Additionally, all of the skills listed here are skills I would expect
even the most junior of penetration testers to possess.

I am not affiliated with Offensive Security, so this is my unofficial guide
based on my own experiences as an OSCP and OSCE.  This is also designed as an
*outline* and not intended to have all of the answers for two reasons:

1. To be successful at OSCP or as a Penetration Tester, you should be able to
   find answers and do research on your own.
2. For those who already have familiarity with some of the topics, reciting all
   of the information would be both pointless and boring.

* TOC
{:toc}

## Basic Skills ##

### Note Taking ###

I know this seems completely unrelated, but trust me: to get the most out of
your PWK experience, you should be able to do an effective job of note taking.
Figure out how to structure your notes, how to keep data associated with
different machines, keeping screenshots with your notes, etc.

There's no single best way to do this, but I separated my notes into two
categories:

* Topical notes, that described information regarding particular
  vulnerabilities, tools, or techniques.  For example, associating particular
  kernel exploits with the versions that they apply to, or notes on techniques
  for pivoting through machines.
* Per-machine notes.  I detailed information on the OS and applications,
  applicable vulnerabilities and exploits, and the technique I ultimately used.
  For most machines, I *also* produced either a python script or metasploit rc
  file to quickly re-exploit the machine, since the machines in the lab can be
  reset at any time by other students.

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

### IP & Ethernet Networking ###

Almost all modern networks use IP at the Network Layer (L3).  Consequently, you
should be familiar with IP networking.  Mostly relevant is IP subnetting and the
difference between routing and switched networks.  Learn what RFC1918 is and why
those IP addresses are special.  It can be helpful to learn how to translate
between representations of CIDR subnets, such as `/24` and `/255.255.255.0`.

You should have an understanding of `No route to host` and how to (potentially)
fix or bypass it.  Understand how a dual-homed host works and how that differs
from a host acting as a router between two networks.  Look at the differences
between broadcast and unicast traffic.

* [IP Protocol](https://en.wikipedia.org/wiki/Internet_protocol_suite)
* [Ethernet](https://en.wikipedia.org/wiki/Ethernet)
* [IP Subnet Calculator](http://jodies.de/ipcalc)

### TCP & UDP ###

You should know about the differences between TCP and UDP.  This includes the
differences in terms of connection establishment and maintenance, as well as the
reliability differences of the two protocols.  Knowing common port numbers of
well-known services will also be helpful.

* [TCP](https://en.wikipedia.org/wiki/Transmission_Control_Protocol)
* [UDP](https://en.wikipedia.org/wiki/User_Datagram_Protocol)
* [List of TCP and UDP Port Numbers](https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers)

### Network Protocols ###

Learn a little bit about some of the common protocols used on networks.  Even if
you don't learn details or read the RFCs, at least reading the Wikipedia article
on some of the most common protocols will be helpful.

* [DNS](https://en.wikipedia.org/wiki/Domain_Name_System)
* [Telnet](https://en.wikipedia.org/wiki/Telnet)
* [SSH](https://en.wikipedia.org/wiki/Secure_Shell)
* [HTTP](https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol)
* [SMB/CIFS](https://en.wikipedia.org/wiki/Server_Message_Block)
* [TLS](https://en.wikipedia.org/wiki/Transport_Layer_Security)

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

## Scripting ##

At a very minimum, being familiar with reading scripts written in Python or Ruby
will be useful.  Many of the exploits on
[Exploit-DB](https://www.exploit-db.com/) are in one of these two languages, so
being able to read them will help you to understand them and modify them if
necessary.  Additionally, Metasploit is written in Ruby, so being able to refer
to this as necessary will be helpful.

It's even better if you can write in one of these languages or another scripting
language.  This will both help you with reproduction scripts (to re-exploit the
same machine again and again after reverts) and will be a very useful skill in
the industry.

## Useful Resources (Books, Sites, etc.) ##

* [Red Team Field Manual](http://amzn.to/2nNHGNc) - Good for remembering quick
  commands and tool executions.
* [Kali Linux Revealed](http://amzn.to/2C5whgl) - Information about Kali Linux
  as a penetration testing distribution.
* [The TCP/IP Guide](http://amzn.to/2Cj521y) - One of the best books I've seen
  for networking protocols.
* [security.stackexchange](https://security.stackexchange.com) - Use for
  research, but don't post questions and expect someone to tell you how to
  perform the exploit right off the bat.
* [/r/netsec](https://reddit.com/r/netsec),
  [/r/netsecstudents](https://reddit.com/r/netsecstudents),
  [/r/asknetsec](https://reddit.com/r/asknetsec) - All great options for
  learning about security, and lots of students going for PWK and OSCP on
  /r/netsecstudents
