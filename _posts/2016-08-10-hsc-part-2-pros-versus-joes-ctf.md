---
layout: post
title: "HSC Part 2: Pros versus Joes CTF"
category: Blog
date: 2016-08-10
tags:
  - CTF
  - BSidesLV
  - BSides
---

Continuing my [Hacker Summer Camp Series](/2016/08/09/hsc-part-i-hardware-hacking-with-the-hardsploit-framework),
I'm going to talk about one of my Hacker Summer Camp traditions.
That's right, it's the Pros versus Joes CTF at BSidesLV.  I've
written [about my experiences](/2015/08/12/hacker-summer-camp-2015-bsides-lv-pros-vs-joes-ctf/)
and even a [player's guide](/2015/08/15/blue-team-players-guide-for-pros-vs-joes-ctf/)
before, but this was my first year as a Pro, captaining a blue team (The SYNdicate).

It's important to me to start by congratulating all of the Joes -- this is an
intense two days, and your pushing through it is a feat in and of itself.  In
past years, we had players burn out early, but I'm proud to say that nearly all
of the Joes (from every team) worked hard until the final scorched earth.  Every
one of the players on my team was outstanding and worked their ass off for this
CTF, and it paid off, as The SYNdicate was declared the victors of the 2016
BSides LV Pros versus Joes.

![Scorched Earth](/img/blog/hsc2016/scorched_earth.png)

### What worked well ###

Our team put in *incredible* amounts of effort into preparation.  We built
hardening scripts, discussed strategy, and planned our "first hour".  Keep in
mind that PvJ simulates you being brought in to harden a network under active
attack, so the first hour is absolutely critical.  If you are well and
thoroughly pwned in that time, getting the red cell out is going to be *hard*.
There's a lot of ways to persist, and finding them all is time consuming
(especially since neither I nor my lieutenant does much IR).

We really jelled as a team and worked very, very, well together on the 2nd day.
We hardened faster than I thought was possible and got our network *very* locked
down.  In that day, we only lost 1000 points via beacons (10 minutes on one
Windows XP host).  Our network was reportedly very secure, but I don't know how
thoroughly the other teams were checking versus the "low hanging fruit"
approach.

### What didn't work well ###

The first day, we did not coordinate well.  We had machines that hadn't been
touched for hardening even after 4 hours.  I failed when setting up the firewall
and blocked ICMP for a while, causing all of our services to score as down.
I've said it before and I'll say it again: coordination and organization are the
most important aspects of working as a team in this environment.

### The Controversy ###

There was an issue with scoring during the competition where tickets were being
counted incorrectly.  For example, my team had ticket points deducted even when
we had 0 open tickets: the normal behavior being that only when you had a ticket
open would you lose points.  This resulted in massive ticket deductions showing
up on the scoreboard, which Dichotomy was only able to correct after gameplay
had ended.  This was a very controversial issue because it resulted in the team
that was leading on the scoreboard dropping to last place and pushed my team to
the top.  The final scoring (announced on Twitter) was in accordance with the
written rules as opposed to the scoreboard, but it still was confusing for every
team involved.

### Conclusion ###

Overall, this was a good game, and I'm very proud of my lieutenant, my joes, and
all of the other teams for playing so well.  I'm also very appreciative of the
hard work from Dichotomy, Gold Cell, and Grey Cell in doing all of the things
necessary to make this game possible.  This game is the closest thing to a live
fire security exercise I've ever seen at a conference, and I think we all have
something to learn from that environment.
