---
layout: post
title: "HSC Part 3: DEF CON"
category: Blog
date: 2016-08-10
---

This is the 3rd, and final, post in my Hacker Summer Camp 2016 series.
[Part 1](2016/08/09/hsc-part-i-hardware-hacking-with-the-hardsploit-framework.html)
covered my class at Black Hat, and [Part 2](/2016/08/10/hsc-part-2-pros-versus-joes-ctf.html)
the 2016 BSidesLV Pros versus Joes CTF.  Now it's time to talk about the
capstone of the week: DEF CON.

DEF CON is the world's largest (but not oldest) Hacker conference.  This year
was the biggest yet, with Dark Tangent stating that they produced 22,000
lanyards -- and ran out of lanyards.  That's a lot of attendees.  It covered
both the Paris and Bally's conference areas, and that *still* didn't feel like
enough.

DEF CON is also what I measure my year by.  You can have your New Year's, I
measure mine from August to August (though apparently next year it'll be the end
of July...).  Probably the single biggest regret in my life is that I didn't
find a way to go to DEF CON before DEF CON 20.  The people and experiences there
are memorable and well worth it.

### Crowds ###

I don't talk about it a whole lot, but I actually have pretty bad social
anxiety.  I do a terrible job of talking with people I don't know, introducing
myself to people, etc.  At most events, I'm what you would call a "wallflower".
That doesn't combine very well with 22,000 people.  That especially doesn't
combine well with the chokepoints in a number of places, especially the packet
capture village.  It was hard to get through the week, but I told myself I
wasn't going to let my social anxiety ruin my con, and I think I did a good job
of that.

### Capture the Packet ###

So, since DEF CON 21, I've always played in Capture the Packet.  At DC22, I even
managed a 2nd place overall finish (just one spot away from the coveted black
Uber badge).  This year, I went back to play and discovered major changes:

- Rounds are now two hours instead of 1.
- There is now a qualifying round, semifinals, and finals.
- They're really pulling out the obscure protocols.
- Significantly lower submit attempt limits (like 1-2 in most questions).

On the other hand, they had serious gameplay issues that really makes me regret
spending so much of my con this year on Capture the Packet.  These include:

- Every round started late.  The finals were supposed to start at 10:00 on
  Sunday, they started at 12:30.  That was two and a half hours of sitting there
  waiting.
- There were many answers where the answer in the database contained typos.
- There were many answers where the question contained typos that made it
  difficult or impossible to find the traffic (wrong IP, wrong MAC, etc.)
- There were many questions that were very poorly phrased.  It was nearly
  impossible to parse some of the questions.  One question asked for the "last
  three hex" of a value, but it wasn't clear: last 3 bytes in hex format, last 3
  hex characters, etc.

Combining the problems with questions and the lowered submission limits, it
meant that several times we were locked out of questions just because it wasn't
clear what format the answer should be or how much data they wanted.  The
organizers clearly need to:

- Increase the limits.  (I'm not asking for unlimited tries, but on text
  answers, give us at least 3-5.)
- Build some sort of fuzzy matching (case insensitive, automatically strip
  whitespace leading/trailing, etc.)
- Write questions more clearly.

I'm actually amazed that Aries Security is able to sell CTP as a commercial
offering for training to government and companies.  It's a wonderful concept and
they try hard, but I'm so disappointed in the outcome.  I spent ~12 hours
sitting in the CTP area, but only 6 of those were actually playing.  The other 6
were waiting for games to start, and then the games were disheartening when they
didn't work correctly.  I'll probably play again next year, but I really hope
they've put some polish on the game by then.

### Parties ###

As usual, DEF CON had a variety of parties to choose from.  Most importantly, I
got my hit of [Dual Core](http://dualcoremusic.com/nerdcore/) in at the Friday
night EDM night, and spent a little bit of time at the Queercon pool party.
(Though it was too hot and humid to spend much time by the pool unless you were
in the pool, and I'm not someone anyone wants in the pool...)

![Dual Core nailing it Friday night](/img/blog/hsc2016/dualcore.jpg)

Just keeping track of all of the parties has become a major task, but the
[DCP](http://defconparties.info/) guys have you covered there.  I'd love to see
some more parties that are a little more "chill": less loud music, more just
hanging out and having a drink with friends.  (Or maybe I was just at all the
wrong ones this year.)

### Next Year ###

I can't wait for next year -- DEF CON 25 promises to be *big*, and we're moving
over to Caesars (2 years is all we got out of Bally's/Paris).  I'm trying to
come up with ideas of how I can make my own personal DEF CON 25 bigger and
better, without ripping off ideas like the AND!XOR badge, but I want to do
something cool.  Suggestions to [@Matir](https://twitter.com/matir) or find my
email if you know me.  :)  Hopefully I'll see all of you, my hacker friends, out
in Las Vegas for another fun Hacker Summer Camp.
