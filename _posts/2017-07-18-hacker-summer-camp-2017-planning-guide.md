---
layout: post
title: "Hacker Summer Camp 2017 Planning Guide"
category: Security
date: 2017-07-18
tags:
  - Hacker Summer Camp
  - Security
  - DEF CON
---

My hacker summer camp planning posts are among the most-viewed on my blog, and I
was recently reminded I hadn't done one for 2017 yet, despite it being just
around the corner!

Though many tips will be similar, feel free to check out the two posts from last
year as well:

* [Hacker Summer Camp Planning Guide](/2016/02/18/hacker-summer-camp-planning-guide.html)
* [Hacker Summer Camp Planning Guide, Part II](/2016/07/08/hacker-summer-camp-planning-guide-part-ii.html)

If you don't know, Hacker Summer Camp is a nickname for 3 information security
conferences in one week in Las Vegas every July/August.  This includes Black
Hat, BSides Las Vegas, and DEF CON.

Black Hat is the most "corporate" of the 3 events, with a large area of vendor
booths, great talks (though not all are super-technical) and a very
corporate/organized feel.  If you want a serious, straight-edge security
conference, Black Hat is for you.  Admission is several thousand dollars, so
most attendees are either self-employed and writing it off, or paid by their
employer.

BSides Las Vegas is a much smaller (~1000 people) conference, that's heavily
community-focused.  With tracks intended for those new to the industry, getting
hired, and a variety of technical talks, it has something for everyone.  It also
has my favorite CTF: [Pros vs Joes](http://prosversusjoes.net/).  You can donate
for admission, or get in line for one of ~450 free admissions.  (Yes, the line
starts early.  Yes, it quickly sells out.)

DEF CON is the biggest of the conferences.  (And, in my opinion, the "main
event".)  I think of DEF CON as the Burning Man of hacker conferences: yes,
there's tons of talks, but it's also a huge opportunity for members of the
community to show off what they're doing.  It's also a huge party at night: tons
of music, drinking, pool parties.  At DEF CON, there is more to do than can be
done, so you'll need to pick and choose.

Hopefully you already have your travel plans (hotel/airfare/etc.) sorted.  It's
a bit late for me to provide advice there this year.  :)

## What To Do ##

Make sure you *do* things.  You only get out of Hacker Summer Camp what you put
into it.  You can totally just go and sit in conference rooms and listen to
talks, but you're not going to get as much out of it as you otherwise could.

Black Hat has excellent classes, so you can get into significantly more depth
than a 45 minute talk would allow.  If you have the opportunity (they're
expensive), you should take one.

If you're not attending Black Hat, come over to BSides Las Vegas.  They go on in
parallel, so it's a good opportunity for a cheaper option and for a more
community feel.  At BSides, you can meet some great members of the community,
hear some talks in a smaller intimate setting (you might actually have a chance
to talk to the speaker afterwards), and generally have a more laid-back time
than Black Hat.

DEF CON is entirely up to you: go to talks, or don't.  Go to villages and meet
people, see what they're doing, get hands on with things.  Go to the vendor area
and buy some lockpicks, WiFi pineapples, or more black t-shirts.  Drink with
some of the smartest people in the industry.  You never know who you'll meet.
Whatever you choose, you can have a blast, but you need to make sure you manage
your energy.  I've made myself physically sick by trying to do it all -- just
accept that you can't and take it easy.

I'm particularly excited to check out the IoT village again this year.  (As
regular readers know, I have a soft spot for the Insecurity of Things.)
Likewise, I look forward to seeing small talks in the villages.

Whatever you do, be an active participant. I’ve personally spent too much time
not participating: not talking, not engaging, not doing. You won’t get the most
out of this week by being a wallflower.

## Digital Security ##

DEF CON has a reputation for being the most dangerous network in the world, but
I believe that title depends on how you look at it.  In my experience, it's a
matter of quality vs quantity.  While I have no doubt that the open WiFi at DEF
CON probably has far *more* than it's fair share of various hijinks (sniffing,
ARP spoofing, HTTPS downgrades, fake APs, etc.), I genuinely don't anticipate
seeing high-value 0-days being deployed on this network.  Using an 0-day on the
DEF CON network is *going* to burn it: someone will see it and your 0-day is
over.  Some of the best malware reversers and forensics experts in the world are
present, I don't anticipate someone using a high-quality bug in modern software
on this network and wasting it like that.

Obviously, I can't make any guarantees, but the following advice approximately
matches my own threat model.  If you plan to connect to shady networks or
CTF-type networks, you probably want to take additional precautions.  (Like
using a separate laptop, which is the approach I'm taking this year.)

That being said, you should take reasonable precautions against more run of the
mill attacks:

- Use Full Disk Encryption (in case your device gets lost/stolen)
- Be fully updated on a modern OS (putting off patches?  might be the time to
  fix that)
- Don't use open WiFi
- Turn off any radios you're not using (WiFi, BT)
- Disable 3G downgrade on your phone if you can (LTE only)
- Don't accept updates offered while you're in Vegas
- Don't run random downloads :)
- Run a local firewall dropping all unexpected traffic

Using a current, fully patched iOS or Android device should be relatively safe.
ChromeOS is a good choice if you just need internet from a laptop-style device.
Fully patched Windows/Linux/OS X are probably okay, but you have somewhat larger
attack surface and less protection against drive-by malware.

Your single biggest concern on *any* network (DEF CON or not) should be sending
plaintext over the network.  Use a VPN.  Use HTTPS.  Be especially wary of
phishing.  Use 2-Factor.  (Ideally U2F, which is cryptographically designed to
be unphishable.)

## Personal Security & Safety ##

This is Vegas.  DEF CON aside, watch what you're doing.  There are plenty of
pick pockets, con men, and general thieves in Las Vegas.  They're there to prey
on tourists, and whether you're there for a good time or for a con, you're their
prey.  Keep your wits about you.

Check ATMs for skimmers.  (This is a good life pro tip.)
Don't use the ATMs near the con.  If you're not sure if you can tell if an ATM
has a skimmer: bring enough cash in advance.  Lock it in your in-room safe.

Does your hotel use RFID-based door locks?  May I suggest
[RFID-blocking sleeves](http://amzn.to/2u6zMCt)?

Planning to drink?  (I am.)  Make sure you drink water too.  Vegas is super-hot,
and dehydration will make you very sick (or worse).  I try to drink 1/2 a liter
of water for every drink I have, but I rarely meet that goal.  It's still a good
goal to have.

## FAQ ##

**Are you paranoid?**

Maybe.  I get paid to execute attacks and think like an attacker, so it comes
with the territory.  I'm going to an event to see other people who do the same
thing.  I'm not convinced the paranoia is unwarranted.

**Will I get hacked?**

Probably not, if you spend a little time preparing.

**Should I go to talks?**

Are they interesting to you?  Go to talks if they're interesting and timely.
Note that most talks are recorded and will be posted online a couple of months
after the conferences (or can be bought sooner from Source of Knowledge). A
**notable exception** is that **SkyTalks are not recorded**.  And don't try to
record them yourself -- you'll get bounced from the room.

**What's the 3-2-1 rule?**

3 hours of sleep, 2 meals, and 1 shower.  Every day.  I prefer 2 showers
myself -- Vegas is pretty hot.
