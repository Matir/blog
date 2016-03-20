---
layout: post
title: "DerbyCon CTF"
date: 2013-09-29 22:38:19 +0000
permalink: /2013/09/29/derbycon-ctf/
category: Security
tags:
  - CTF
  - Security
---
While at Derbycon last weekend, I played in the Derbycon Capture the Flag (CTF).  I played with some people from the DefCon Group back in Atlanta (DC404) -- and we had a great team and that lead to a 5th place finish out of more than 80 teams with points on the board.  Big shout out to Michael (@decreasedsales), Aaron (@aaronmelton), Dan (@alltrueic), and all the others who helped out.

It was an attack-only format, with a range of IPs designated as "in scope" and the goal being to, as the name implies, capture the flags.  The systems included a Windows Active Directory server, a handful of Linux webservers, and a Windows Server serving up ASP.net backed by MS-SQL.  One of the Linux webservers had a variety of challenges in directories on it, most of which could be solved offline.  These included a Windows 8 memory dump for forensics, a series of encrypted hashes for some crypto, a pcap for network forensics, and some obfuscation/general challenges.

Every time I do a CTF, I learn a bunch of new stuff, mostly about my weaknesses and where I need to improve.

 - Windows AD Skills
 - MS SQL Skills
 - Binary Reversing
 - Memory Forensics

I'll try to do a writeup of a few of the challenges in the next few days, as I'm just recovering from a post-con flu.
