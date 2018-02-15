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
date: 2018-02-14
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

# Preparation

## Basic Skills ##

Beyond being able to do research (for example, find manpages, MSDN
documentation, exploits, vulnerabilities), time management (to get through the
course in a timely fashion), and learning new technical skills, there are some
less-obvious basic skills that will still be very useful in taking PWK and
passing the OSCP exam.

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

The best way to get started is to just download a distribution, throw it into a
VM, and start using it for a while.  (And if you've never run a VM, you should
learn that too -- the custom Kali build provided is provided as a VM image.)
Try doing some "daily driver" tasks, and get used to the interface.  Setup and
run the SSH server, and try SSHing in.

[Bandit](http://overthewire.org/wargames/bandit/) from OverTheWire is a great
free "wargame" that teaches Linux basics as well.  It's free and a great place
to get started.  If you can make it through that, you're well on your way to the
basic Linux knowledge to move on with PWK.

### Knowing What You Don't Know ###

One of the hardest things to do in life is to know what you don't know.  Finding
the gaps in your knowledge so you know what to research and how to fill those
gaps can be quite challenging.  Take a look at the
[Syllabus](https://www.offensive-security.com/documentation/penetration-testing-with-kali.pdf)
for the PWK course.  If you find yourself even confused by the headers, you can
research more and spend more time getting some basic familiarity with the
concepts and terminology.

Obviously, the class will teach you about a lot of the material, but if you're
completely lost with even what the titles mean, you might have a hard time
following along and definitely won't be spending as much time working on the
labs as you might like.

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

## Operating Systems & Applications ##

Knowing how operating systems function at a basic level will be very useful.
This includes the differences between operating systems, how processes work, how
the filesystems work, and certainly information about authentication &
authorization on each operating system.

### Linux ###

Understanding the different types of authentication and authorization mechanisms
on Linux systems is critical, as well as operating system interfaces and common
services.

* The [root user](https://en.wikipedia.org/wiki/Superuser)
* [setuid](https://en.wikipedia.org/wiki/Setuid) Binaries
* POSIX Users & Groups
* POSIX [Filesystem
  permissions](https://en.wikipedia.org/wiki/File_system_permissions)
* SELinux & AppArmor
* File locations (`/etc/passwd`, `/etc/shadow`, etc.)
* How Services Are Started (SysV `init`, Upstart, `systemd`)

### Windows ###

Windows has very different behavior from Linux and POSIX systems in many
regards.  Most PWK students are probably familiar with Windows on the Desktop,
but a multi-user environment or Windows domain may be unfamiliar, unless the
student has prior experience in the help desk, system administration, or similar
roles.

* Users and Groups
* [Filesystem
  Permissions](https://msdn.microsoft.com/en-us/library/bb727008.aspx)
* [Windows Services](https://en.wikipedia.org/wiki/Windows_service)
* [Domain
  Authentication](https://msdn.microsoft.com/en-us/library/ee253152%28v=bts.10%29.aspx)
* SMB/CIFS Resources

### Applications ###

Some of this is OS-independent, or may differ from OS to OS, but should still be
known.  Generally, database servers (MySQL/MSSQL/PostgreSQL) and application
servers are a big part of the attack surface of any modern enterprise, and the
PWK lab is no different.  For example, knowing about different webservers
(Apache, nginx, IIS) and mechanisms for loading web applications (`mod_php`,
`cgi` scripts, `php-fpm`, Python `WSGI`, and ASP.net).  Not all of these are
critical, but a general familiarity will be useful.

In a typical enterprise environment (which the PWK labs and exam are designed to
emulate), there will be dozens of web applications, most of which are backed by
database servers or other application servers.

## Security Topics ##

Obviously, PWK is mostly about learning security skills, but there should be
some fundamental knowledge that a student brings to the table.  Having an
understanding of security fundamentals will serve the student well during the
PWK course.

* [The CIA Triad](https://www.cylance.com/en_us/blog/all-about-the-cia-triad.html)
  (Confidentiality, Integrity, and Availability)
* [Authentication](https://en.wikipedia.org/wiki/Information_security#Authentication)
  vs
  [Authorization](https://en.wikipedia.org/wiki/Information_security#Authorization)
* [Memory Corruption Vulnerabilities](https://en.wikipedia.org/wiki/Memory_corruption)
* [Web Vulnerabilities](https://www.owasp.org/index.php/Category:OWASP_Top_Ten_Project) (perhaps OWASP Top 10)

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

# Getting the Most Out of PWK #

Though this post is focused on preparing for the course, I wanted to provide
some input on how to get the most out of your coursework and lab time.  These
are based on my experiences and your learning style and experience may vary.

## Document, Document, Document ##

I put note-taking as one the top skills, and now I'll put it as one of the
activities you should focus on during the course.  Taking notes will help you
retain your learning more effectively, and, since the exam is open-book, may
well help you on the exam.  Plus, if you choose to submit a report for the lab
as well as the exam, you can use this documentation to produce the lab report.

Documentation can take many forms during the course:

* Notes, whether hand-written or typed
* Network diagrams
* Shell logs/command line logs
* Screenshots (especially useful for Graphical tools)

When in doubt, take *extra* documentation.  A couple of minutes here or there
might pay off in the long run.  I treated the lab like a "real" penetration
test, where I documented each compromised machine with:

* Enumeration/Recon information
* Vulnerability & exploit used to compromise it
* Dumped hashes/accounts found
* Screenshot of machine access
* Privilege escalation information
* Any useful artifacts (documentation, files, mounted file shares, etc.)

## Recon ##

I cannot stress enough the value of the recon & enumeration phase.  Thoroughly
collecting information will help you to identify vulnerabilities and understand
how the network fits together.  The lab environment is not just a bunch of
computers -- it truly is a network with interconnected components, and
recognizing it as such during the recon phase will make you far more successful.
For example, understanding the relationship between machines will dramatically
help in pivoting between hosts and network segments.  Understanding the role of
the machine helps you determine how the machine might benefit you (application
servers likely have access to database servers; admin workstations likely have
access to a wide variety of things; etc.).

## Time Management ##

There's several aspects to your time management throughout the course.  I can
highly recommend *not* dividing your time between course material and labs like
I did.  I barely started watching the lab videos, binge-read the lab book, and
then moved directly into the labs online.  I never did finish watching the lab
videos, and while that happened to work out for me, I don't think it's actually
a good model to follow.

I recommend skimming the lab book to get an overall understanding of the
progression of the course, then going back and going through the labs, videos,
and exercises together.  If you want to get the most out of your course, I would
suggest trying to get through all the course material in about half the lab
time, because the course material does not get you every machine in the lab.
The other half of the time can be used to work independently on all the rest of
the machines in the lab environment.

If you are going for a 60 or 90 day lab period and you worry about not passing
the OSCP exam on the first try (I hear it's quite common to fail before
eventually succeeding), I suggest making an exam attempt about 15 days before
the end of your lab time.  If you do this and fail, you'll have the opportunity
to revisit the lab and brush up on your weak areas before making another exam
attempt.  (Note that Offensive Security reportedly has a number of different
exam setups, so you won't get the exact same machines, but you should still have
a good idea of where your weaknesses lie.)

# Useful Resources (Books, Sites, etc.) #

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
* [The Linux Command Line: A Complete Introduction](http://amzn.to/2EtotLh)
* [Penetration Testing: A Hands-On Introduction to
  Hacking](http://amzn.to/2GhiYM5) - Good basics for penetration testing.
* [Hacking: The Art of Exploitation](http://amzn.to/2EvTxdd) - Not necessary for
  taking PWK/OSCP, but a good resource to expand your knowledge.

## Other OSCP Prep Guides ##

* [Blade Soriano at Alien
  Vault](https://www.alienvault.com/blogs/security-essentials/how-to-prepare-to-take-the-oscp)
* [Ramkisan Mohan at Network
  Intelligence](http://niiconsulting.com/checkmate/2017/06/a-detail-guide-on-oscp-preparation-from-newbie-to-oscp/)
