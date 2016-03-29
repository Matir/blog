---
layout: post
title: "Another Milestone: Offensive Security Certified Expert"
category: Security
date: 2016-03-28
tags:
  - OSCE
  - Offensive Security
  - Security
---

This weekend, I attempted what might possibly be my hardest academic feat ever:
to pass the Offensive Security Certified Expert exam, the culmination of
OffSec's Cracking the Perimeter course.  48 hours of being pushed
to my limits, followed by 24 hours of time to write a report detailing my
exploits.  I expected quite a challenge, but it really pushed me to my limits.
The worst part of all, however, was the 50 hours or so that passed between the
time I submitted my exam report and the time I got my response.

![OSCE][1]

For obvious reasons (and to comply with their student code of conduct), I can't 
reveal details of the exam nor the exact contents of the course, but I did want
to review a few things about it.

#### The Course ####

The course covers a variety of topics ranging from web exploitation to bypassing
anti-virus to custom shellcoding with egghunters and restricted character sets.
The combination of different techniques to exploit services is also covered.
While there are web topics that will obviously apply to all operating systems,
all of the memory corruption exploits and anti-virus bypass are targeting
Windows systems, though the techniques discussed mostly apply to any operating
system.  (There is discussion of SEH exploits, which is obviously
Windows-specific.)

**Compared to PWK**, there's a number of differences.  PWK focuses mostly on
identifying, assessing, and exploiting publicly-known vulnerabilities in a
network in the setting of a penetration test.  CTP focuses on identifying and
exploiting newly-discovered vulnerabilties (i.e., 0-days) as well as bypassing
limited protections.  While PWK has a massive lab environment for you to
compromise, the CTP lab environment is much smaller and you have access to all
the systems in there.  The CTP lab, rather than being a target environment, is
essentially a lab for creating proofs-of-concept.

My biggest disappointment with the CTP lab is the lack of novel targets or
exercises compared to the material presented in the coursebook and videos.  For
the most part, you're recreating the coursebook material and experiencing it for
yourself, but I almost felt a bit spoonfed by the availability of information
from the coursebook when performing the labs.  I would have liked more exercises
to practice the described techniques on targets that were not described in the
course materials.

Depending on how many hours a day you can spend on it and your previous
experience, you may only need 30 days of lab time.  I bought 60, but I think I
would've been fine with 30.  (On the other hand, I appreciated having 60 days
for the PWK lab.)

#### The Exam ####

If you've successfully completed (*and understood*) all of the lab material,
you'll be well-prepared for the exam.  The course material prepares you well,
and the exam focuses on the core concepts from the course.

The exam has a total of 90 points of challenges, and 75 points are required to
pass.  I don't know if everyone's exam has the same number and point value of
challenges (though I suspect they do), but I'll point out that more than one of
my challenges on the exam was worth more than the 15 points you're allowed to
miss.  Put another way, some of the challenges are mandatory to complete on the
exam.

The exam is difficult, but not overly so if you're well prepared.  I began at
about 0800 on Friday, and went until 0100 Saturday morning, then slept for about
5 hours, then put in another 3 or 4 hours of effort.  At that point, I had
managed the core of all of the objectives and felt I had refined my techniques
and exploits as far as I could.  Though there was a point or two where it could
have gotten better, I wasn't sure I could do that in even 24 hours, so I moved
on to the report -- I figured I'd rather get a good report and have access to
the lab to get any last minute data, screenshots, or fix anything I realized I
screwed up.  About noon, I had my report done and emailed, and began waiting for
results.  The fact that my F5 key is now worn down is purely coincidence.  :)

Tips:

- Be well rested when you begin.
- Don't think you'll power through the full 48 hours.  At a certain energy level,
  you've hit a point of diminishing returns and will start even working
  backwards by making more mistakes than you can make headway.
- You'll want caffeine, but moderate your intake.  Jumpy and jittery isn't
  clear-headed either.
- Take good notes.  You'll thank yourself when you write the report.

#### Conclusion ####

The Cracking the Perimeter class is totally worth the experience.  Before this
class, I'd never implemented an egghunter, and I'd barely even touched Win32
exploitation.  Though some people have complained that the material is dated, I
believe it's a case of "you have to walk before you can run", and I definitely
feel the material is still relevant.  (That's not to say it couldn't use a bit
of an update, but it's definitely useful.)  Now I have to find my next course.
(Too bad AWE and AWAE are always all full-up at Black Hat!)

[1]: /img/blog/osce.png
