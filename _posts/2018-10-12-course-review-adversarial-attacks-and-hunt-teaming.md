---
layout: post
title: "Course Review: Adversarial Attacks and Hunt Teaming"
category: Security
date: 2018-10-12
tags:
  - Training
  - Course Review
---

At DerbyCon 8, I had the opportunity to take the "Adversarial Attacks and Hunt
Teaming" presented by Ben Ten and Larry Spohn from TrustedSec.  I went into the
course hoping to get a refresher on the latest techniques for Windows domains (I
do mostly Linux, IoT & Web Apps at work) as well as to get a better
understanding of how hunt teaming is done.  (As a Red Teamer, I feel
understanding the work done by the blue team is critical to better success and
reducing detection.) <!--more-->  From the course description:

> This course is completely hands-on, focusing on the latest attack techniques
> and building a defense strategy around them. This workshop will cover both red
> and blue team efforts and provide methods for understanding how to best detect
> threats in an enterprise. It will give penetration testers the ability to
> learn the newest techniques, as well as teach blue teamers how to defend
> against them.

### The Good ###

The course was definitely hands-on, which I really appreciate as someone who
learns by "doing" rather than by listening to someone talk.  Both instructors
were obviously knowledgeable and able to answer questions about how tools and
techniques work.  It's really valuable to understand *why* things work instead
of just running commands blindly.  Having the *why* lets you pivot your
knowledge to other tools when your first choice isn't working for some reason.
(AV, endpoint protection, etc.)

Both instructors are strong teachers with an obvious passion for what they do.
They presented the material well and *mostly* at a reasonable pace.  They also
tag-team well: while one is presenting, the other can help students having
issues without delaying the entire class.

The final lab/exam was really good.  We were challenged to get Domain Admin on a
network we hadn't seen so far, with the top 5 finishers receiving challenge
coins.  Despite how little I do with Windows, I was happy to be one of the
recipients!

![TrustedSec Coin](/img/blog/trustedsec_coin.jpg){:.center}

### The Bad ###

The course began quite slowly for my experience level.  The first half-day or so
involved basic reconnaisance with nmap and an introduction to Metasploit.  While
I understand that not everyone has experience with these tools, the course
description did not make me feel like it would be as basic as was presented.

There was a section on physical attacks that, while extremely interesting, was
not really a good fit for the rest of the course material.  It was too brief to
really learn how to execute these attacks from a Red Team perspective, and
physical security is often out of scope for the Blue Team (or handled by a
different group).  Other than entertainment value, I do not feel like it added
anything to the course.

I would have liked a little more "Blue" content.  The hunt-teaming section was
mostly about configuring Windows Logging and pointing it to an ELK server for
aggregation and analysis.  Again, this was interesting, but we did not dive into
other sources of data (network firewalls, non-Windows systems, etc.) like I
hoped we would.  It also did not spend any time discussing how to relate
different events, only how to log the events you would want to look for.

### Summary ###

Overall, I think this is a good course presented by excellent instructors.
If you've done an OSCP course or even basic penetration testing, expect some
duplication in the first day or so, but there will still be techniques that you
might not have seen (or had the chance to try out) before.  This was my first
time trying the
"[Kerberoasting](https://www.harmj0y.net/blog/powershell/kerberoasting-without-mimikatz/)"
attack, so it was nice to be able to do it hands-on.  Overall a solid course,
but I'd generally recommend it to those early in their careers or transitioning
to an offensive security role.
