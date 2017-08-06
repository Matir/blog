---
layout: post
title: "Hacker Summer Camp 2017: Pros vs Joes CTF"
category: Security
date: 2017-07-31
series: Hacker Summer Camp 2017
tags:
  - Security
  - Hacker Summer Camp
  - Pros vs Joes
  - CTF
---

I've returned from this year's edition of Hacker Summer Camp, and while I'm
completely and utterly exhausted, I wanted to get my thoughts about this year's
events out before I completely forget what happened.

The Pros vs Joes CTF was, yet again, a high quality event despite the usual
bumps and twists.  This was the largest PvJ ever, with more than 80 people
involved between Blue Pros, Blue Joes, Red Cell, Grey Cell, and Gold Cell.  Each
blue team had 11 players between the two Pros and 9 Joes, making them slightly
larger than in years past.  (Though I believe that's a temporary "feature" of
this year's game.)

I was also incredibly happy by the diversity displayed by the event this year:
at least 3 of the blue teams had women on them, as did both Gold and Grey cells.
Teams had experienced players, with some being veterans, as well as players with
no professional experience (students) and professionals working outside the
information security industry (my team alone had two electrical engineers).
This mix is part of what makes Pros vs Joes so good -- everybody has something
to contribute, and you get such a wide range of views and experiences.  Two
players on my team absolutely *crushed* the Windows aspects of the game, which
was incredible because everyone knows I'm a hardcore Linux guy.  (The last
version of Windows I used as a "daily driver" was Windows XP SP 2.  In 2003.)

Game mechanics were incredibly different this year than in years past.  No
longer did a team turn in "integrity flags" for local points.  More hosts had
multiple scored services.  Tickets incurred a penality if they were reopened.
Most signiciantly, there was a store where teams could buy a variety of things,
including the services of a Red Team member, a Security Onion box (I gotta give
Security Onion a try!), or "outsourcing" a grey team ticket.  My team chose to
make little use of this store, but other teams made extensive use of Dichotomy's
Emporium.  (I'm not convinced that either is an "optimal" strategy, because a
lot depends on the strengths and weaknesses of their own team.)  I can't wait to
see the analysis from our data scientist on the different aspects of the game.

The game environment, on the other hand, was essentially unchanged from last
year.  The same vulnerabilities and hosts were present.  This lead to quite a
bit of surprise when, during scorched earth, I was able to use the same BIND 9
bug to take out DNS (and consequently, the ability of Scorebot to reach any
services) for all 3 other teams (which was a repeat of my same scorched earth
tactic from last year).  A note to future captains: DNS is important, perhaps
you'd like to patch that machine.

![Scorched Earth](/img/blog/hsc2017/scorched_earth.png)

I'll leave any major announcements about the game to Dichotomy, but I do want to
mention that I envision more collaboration between the Pros & Staff over the
next year.  Pros vs Joes is a learning CTF first, and this will allow us to
build a more immersive environment and a better set of resources for the blue
staff to use in mentoring Joes.

I was exhausted by the end of this PvJ, but it was a kind of good exhaustion.
No matter how tired I was, I was satisfied to know that all of my players seemed
to have learned *something* throughout the course of the game, and the cherry on
top was a victory for ShellAntics.  Thanks to Dichotomy, Gold Cell, Red Cell (no
hard feelings t1v0?), and of course, the awesome Joes on my team.
