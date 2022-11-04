---
layout: post
title: "Hacker Summer Camp 2015: DEF CON"
date: 2015-08-14 03:11:12 +0000
permalink: /2015/08/14/hacker-summer-camp-2015-def-con/
category: Security
tags:
  - DEF CON
  - CTF
  - Security
redirect_from:
  - /blog/hacker-summer-camp-2015-def-con/
---
So, following up on my post on BSides LV 2015, I thought I'd give a summary of DEF CON 23.  I can't cover everything I did (after all, what happens in Vegas, stays in Vegas... mostly) but I'm going to cover the biggest highlights as I saw them.

The first thing to know about my take on DEF CON is that DEF CON is a one-of-a-kind event, somewhere between a security conference and a trip to Mecca.  It's one part conference, one part party, and one part social experience.  The second thing to know about my take on DEF CON is that I'm not there to listen to people speak.  If I was just there to listen to people speak, there's the videos posted to YouTube or available on streaming/DVD from the conference recordings.  I'm at DEF CON to *participate*, *meet people*, and **hack all the things**.

I generally try not to spend my entire DEF CON doing one thing, though I'd probably make an exception if I ever got to play in DEF CON CTF.  (Anyone need a team member? :))  It's a limited time (on papser, 4 days, but really, it's about 2.5 days) and I want to get in all that I can.  This year, I managed to get in a handful of major activities:

1. A Workshop on Auditing Mobile Applications
2. Playing OpenCTF
3. Playing Capture the Packet

I also attended a few talks in the various villages, including the wireless village and the tamper evident village, worked at an event for my employer, and got lots of opportunities for finding out what others are working on and the fun & interesting projects people are doing.  (And perhaps I attended a party or two...)

**Auditing Mobile Applications**

The auditing mobile applications workshop (taught by Sam Bowne, an instructor at CCSF) was interesting, but wasn't as much depth as I'd hoped.  Firstly, it was strictly confined to Android and didn't cover iOS at all (though some of the techniques would still apply).  Secondly, a lot of the attendees were *very inexperienced* at what I would consider basic tooling.  I'm all for classes for every level, but having the *same* class for every level means teaching to the lowest common denominator.  I do have to give him a *lot* of credit for being well prepared: he had his own wireless router, network switches, and even several pre-configured laptops for student use.

The course attempted to cover several aspects of the [OWASP Mobile Top 10](https://www.owasp.org/index.php/Projects/OWASP_Mobile_Security_Project_-_Top_Ten_Mobile_Risks), but mostly focused on applications that failed to use SSL, failed to implement SSL, or failed to implement anti-reversing protections (more on that later).  The first two were basically tested by installing an [emulator](https://www.genymotion.com/), installing [Burp Suite](https://portswigger.net/burp/), and pointing the emulator to Burp.  If traffic was seen as plaintext traffic, well, obviously no SSL was in use.  If traffic was seen as HTTPS traffic, obviously they weren't verifying certificates properly, as Burp was presenting its own self-signed certificate for the domain.  In this case, failing connections was treated as a "success" for validation, though not all of the edge cases were being tested.  (We didn't check for valid chain, but wrong domain, or valid chain + domain, but expired or not yet valid, etc.  There's a lot that goes into SSL validation, but hopefully they're using the system libraries properly.)

Then we got to recovering secrets from APKs.  Sam demonstrated using [apktool](https://ibotpeaches.github.io/Apktool/), which extracts and decompiles APKs to smali (a text-based representation of Dalvik bytecode), to look for things like hard-coded keys, passwords, and other relevant information.  Using apktool is definitely an interesting approach, and shows how trivial it is to extract information from within the APK.

Next Sam started talking about what he called "code injection."  He pointed out that you could take the smali, modify it (such as to log the username & password entered into the app) and then recompile & resign the app, then upload the new version to the play store.  He claimed that this is a security risk, but I quite frankly don't agree with him there.  It's always been possible for an attacker to provide malicious binaries, including those that look like legitimate software.  Though decompiling, modifying, and recompiling may reduce the bar for the attacker, it's still the same attack.  I'm not convinced this is a new threat or really can be mitigated (he suggests code obfuscators), but I think there's room for disagreement on this one.

If you're interested in the details, you can find [Sam's course materials online](https://samsclass.info/128/128_BSidesLV-Defcon-2015.shtml).

**OpenCTF**

OpenCTF is the little brother of the DEF CON CTF, with anyone able to play.  There are a wide range of challenges for any skillset, and even though we didn't spend a whole lot of time playing, we managed a [10th place finish](https://ctftime.org/event/225).  (Team [Shadow Cats](https://ctftime.org/team/4710)).  One of my favorites was aaronp's "Pillars of CTF", which took you on a tour through the various areas commonly seen in CTF: reverse engineering, network forensics, and exploitation.  Each area was relatively simple, but it had great variety and just enough challenge to make it interesting.  Other challenges included web challenges with a bot visiting the website (so client-side exploitation was possible), more difficult PCAP forensics, and plenty of reversing.  I haven't played much CTF lately (before the week in Vegas), but it was really good to get back into it, especially since this was more of a Jeopardy-style CTF than the Attack/Defense in Pros vs Joes.

**Capture the Packet**

I don't do any network forensics at work, but I find it a fascinating area of information security.  Every year (save one) I've been to DEF CON, I've played in the "Capture the Packet" challenge.  Basically, you get a network port on a 100Mb network, and a set of ~15 questions, and you need to find the answers to the questions in the stream of network traffic.  Questions range from "What is the password for ftp user x?" to "There was a SIP call between stations 1001 and 1002.  What was the secret word?"  It's non-trivial, and will stretch anyone but the most seasoned incident responder, but it's a great opportunity to exercise your Wireshark skills.

Pro tip: I like to separate capture from analysis.  If you live capture in Wireshark, it gets slow, and when the number of packets is too large, filtering becomes extremely laggy.  Instead, I'll start tcpdump in a shell session, then analyze the pcaps with Wireshark or other tools.  (I'm contemplating writing a collection of domain-specific tools just for fun, and to help in future CTPs.)  If you're not a tcpdump expert, the command line I use is something like this:

    tcpdump -i eth0 -s 0 -w packets -C 100

What this does is capture on interface eth0, unlimited packet size, write to files named like "packets", and rotate the file every 100 MB.  This way I can keep my cap sizes manageable, but avoid *too much* risk of splitting connections across multiple pcap files.

If you haven't tried CTP before, I really recommend it.  The qualifying round only takes about an hour, and some years (not sure if it was this year) it's a black badge challenge, though you need to qualify + win finals.

**Thoughts on the new venue**

So, this was the first year at Bally's/Paris combined, and it wasn't without growing pains.  The first couple of days, traffic was crazy, especially near the Track 1-4 areas in Paris, but the Goons quickly adapted and got the traffic flowing again (making one-way lanes really helped).

The best part was being on the strip.  It meant it was easy to get to restaurants outside the venue without cabbing, and it was a much more attractive hotel than the Rio.  (Yay no more awkward bathroom windows!)

The worst part, however, is that the conference area at Bally's is all the way in the back, so you have to walk a non-trivial distance between the two areas.  I definitely got my 10,000 steps a day in every day that week.  There's nothing DEF CON can do about this at the current venue, and I can use the exercise.

**Conclusion**

I had a great time, but felt like I didn't do as much as I had hoped.  I'm not sure if this was unrealistic expectations, or just a perception of doing less than I actually did.  I definitely learned new things, met new people, and generally consider it a successful year, but I'm always a little wistful when it ends, and this year was no exception.  I keep telling myself I'll do something interesting enough to end up on the stage one year -- maybe 24's my lucky number.
