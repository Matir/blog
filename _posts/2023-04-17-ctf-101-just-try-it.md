---
layout: post
title: "CTF 101: Just Try It!"
category: Security
date: 2023-04-17
tags:
    - CTF
    - BSidesSF
---

* Table of Contents
{:toc}

As I'm helping to organize the [BSides San Francisco
CTF](https://ctf.bsidessf.net) this weekend, I thought I'd share a little primer
for CTFs for those who have not gotten into them before.

## What is a CTF?

I suspect that most people in the information security ("cybersecurity") space
have already heard of Capture the Flag (or CTF) competitions, but in case you
haven't, I wanted to provide a short overview.

Capture the Flag competitions are a timed and scored set of security-related
challenges.  They may take many forms and durations, but there are some pretty
common styles, and the majority of CTFs are 24-72 hours long.  Some are
associated with conferences or other events, while others are run entirely
online.

The most common style of CTF is called "**Jeopardy Style**", named after the TV
show.  In these CTFs, players complete challenges from an assortment of
categories to earn points.  Most often, completing each challenge awards the
"flag" that is entered into the scoreboard to receive points.  These may be run
for individual players or teams of players.

Another style is the "**Attack-Defense CTF**", in which teams of players have a
network to defend while also being able to attack the networks of other players.
They may involve stealing flags off the opponent's network or planting ones own
flags to earn points.

Most players' first CTF experience will be with a Jeopardy-style CTF
competition, such as the one we're running this weekend, so I'll focus on that
style for the remainder of this post.

## Common Categories

While CTFs may present challenges that are widely varied, there are some
categories that are fairly common across the board.  Beyond those described
below, you'll see varied topics like Mobile, Cloud, or even "Miscellaneous"
where you'll be doing some potentially obscure task.

### Pwnable (Pwn)

As a general rule, these challenges usually have an expectation of gaining some kind of
privileged access, usually in the form of code execution or a shell.  Many of
them involve some form of memory corruption (buffer overflow, use-after-free,
double free, etc.), and some CTF participants would say that pwn should even be
limited to memory corruption.  Usually, it will be a networked binary/service
written in a relatively low-level language.  In any case, these would be the common
"exploitation of a priviliged service".

Solving these may also involve some reverse engineering to understand the
binary, but the focus here is normally on the exploitation of the bug(s) more
than the reverse engineering.  Occasionally, a challenge will provide source
code or other resources.

### Web

Web challenges are incredibly common and only continuing to grow in popularity
with challenge authors over time.  Probably has something to do with nearly
everything being a web app these days.  These challenges involve compromising a
web application, either by server-side vulnerabilities (SQL injection, request
splitting, auth bypass, SSRF) or through client-side vulnerabilities (XSS,
CSRF), or some combination.

For the client-side exploits, most challenges involve some kind of automated
browser visiting the relevant application to be exploited.  (Having to exploit a
browser bug is less common, but also possible.)  For the BSidesSF CTF, we call
this "`webbot`", and use a headless Chrome driven by the puppeteer library.

Web challenges can have a special complexity for challenge authors: shared
state, such as databases, make it easier for players' attempts to interfere with
each other.  (Personally, I try to avoid such state if I can.)

### Forensics

Forensics challenges have a wide variety of challenges to recover some kind of
data from an underlying media.  This might be packet captures, disk images,
memory dumps, steganography or even log analysis.  It's encouraging to see more
responder/blue team oriented content appearing in CTFs, even if I'm personally
terrible at them.

These challenges are great for those in (or looking to get into) SOC, digital
forensics, or other related fields.  Also great for those transitioning from
something like network administration, as some of the topics should be quite
familiar.

### Crypto

Crypto means cryptography!  These challenges typically involve some kind of
custom cryptosystem, though I've also seen bad key generation or incorrect
application of well-known cryptographic primitives.  If you think you're good at
math, spotting patterns, or figuring out weird formats, this might be a category
you can use to test yourself.

Crypto challenges can range from basic Caesar ciphers to mis-applications of
cryptosystems like AES or RSA.  They're also a great opportunity to practice
scripting, as you'll often need to apply your approach to a large volume of
data.

### Reversing (RE)

Reverse Engineering challenges mostly involve a program that needs to be
reverse-engineered to figure out the hidden flag.  Often, they'll ask for an
input and use that input to produce or decrypt the flag and then display them.
These usually tend to be native code (C/C++ or even something like Rust or Go),
but you might also encounter managed code (such as .NET, Java, or Python
bytecode).  Disassemblers and decompilers will be your friend here.

These are great for those who want to understand malware, or want to extend
their reversing skills for better exploitation or other security practices.
I've personally learned so much about the internals of operating systems and
application security from reversing challenges.

## Useful Tools

For a variety of reasons, Linux CTF challenges are far more common than Windows
challenges.  Consequently, you'll probably want some flavor of Linux VM.  It
doesn't have to be something security-specific like Parrot or Kali Linux, but
something you can test things on and run things on.  Don't forget to snapshot
this VM, as it'll give you a clean start each time, as well as reduce the risk
of something going wrong with a challenge attempt completely screwing things up.

For web challenges, having a web proxy that lets your replay and modify HTTP
requests is incredibly useful.  [BurpSuite](https://portswigger.net/burp) is a
bit of a gold standard, but OWASP Zap and mitmproxy are other options.  Having a
VPS or using a "Request Bin" to receive requests online can also be useful.

For reversing, pwnable, and other challenges, you'll want a disassembler like Ghidra,
radare2/rizin, BinaryNinja or IDA.  You'll also probably want a debugger -- I
use `gdb` with the [`gef`](https://github.com/hugsy/gef) script on Linux, and
`windbg` on Windows.

For forensics challenges, there'll be a variety of tools that depend on the
circumstance.  Commonly, though, you'll see challenges involve packet captures
(PCAP), for which Wireshark is just about the *only* answer.

You might need to be able to host files or receive reverse shells.  In such a
case, having a system with a public IP can be incredibly useful.  I tend to use
a VPS for this, as I'm often at a conference or on another network doing Network
Address Translation, which makes receiving incoming connections more difficult.
I mostly use [DigitalOcean](https://m.do.co/c/b2cffefc9c81) because they're
relatively low cost and easy to spin up in a variety of regions, but you can get
some really cheap VPSs if you look on a site like LowEndBox.  For something like
playing in a CTF, the lower reliability of a cheaper option is not a significant
concern.

GCHQ's CyberChef can also be a great tool during CTFs, along with familiarity
with some sort of scripting language.  If you're using Python, I can highly
recommend pwntools when doing reversing or exploitation challenges.

## Benefits of Playing

Probably the most prevalent benefit of playing in CTF competitions is the fun
and enjoyment brought about by solving challenges.  Just like any kind of
puzzle, there is a sense of accomplishment on solving a challenge.  (Especially
something new or difficult to you.)

There is definitely an educational benefit to participating in a CTF as well.
They provide a great opportunity to reinforce an existing skill or try out
something new during a CTF -- the stakes are low, and if well-designed, it
should be possible to solve the puzzle.

Even if one doesn't learn new technical skills, puzzle-like games can stretch
the mind and help improve the ability to think "outside the box."

I've also met some great people through playing and building CTF challenges.
This can be a good networking opportunity, as most of them will be in the
information security space or related areas.

## Advice

I recommend just giving it a try.  Look at a challenge that looks fun, check it
out, and give it a try.  You can get far just by Googling a few things in a lot
of cases, and you might just learn something!
