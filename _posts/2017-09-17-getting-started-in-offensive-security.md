---
layout: post
title: "Getting Started in Offensive Security"
category: Security
date: 2017-09-17
tags:
  - Education
  - Getting Started
  - Red Teaming
  - Penetration Testing
excerpt: |
  Information security is a large field with a variety of required skillsets and
  backgrounds.  It also is an exciting field with many people interested in
  getting started.  These are my thoughts on getting into the offensive security
  space.
---

**Please note that this post, like all of those on my blog, represents only my
views, and not those of my employer.  Nothing in here implies official hiring
policy or requirements.**

I'm not going to pretend that this article is unique or has magic bullets to get
you into the offensive security space.  I also won't pretend to speak for others
in that space or in other areas of information security.  It's a big field, and
it turns out that a lot of us have opinions about it.

My personal area of interest -- some would even say expertise -- is offensive
application security, which includes activities like black box application
testing, reverse engineering (but not, generally, malware reversing),
penetration testing, and red teaming.  I also do whitebox code review and
various other things, but mostly I attack things using the same tools and
techniques that an illicit attacker would.  Of course, I do this in the interest
of securing those systems and learning from the experience to help engineer
stronger and more robust systems.

I do a lot of work with recruiting and outreach in our company, so I've had the
chance to talk to many people about what I think makes a good offensive security
engineer.  After a few dozen times and much reflection, I decided to write out
my thoughts on getting started.  Don't believe this is all you need, but it
should help you get started.

* Table of Contents
{:toc}

## A Strong Sense of Curiousity and a Desire to Learn ##

This isn't a field or a speciality that you get into after a few courses and can
stop there.  To be successful, you'll have to constantly keep learning.  To keep
learning like that, you have to *want* to keep learning.  I spend a lot of my
weekends and evenings playing with technology because I want to understand how
it works (and consequently, how I can break it).  There's a lot of ways to learn
things that are relevant to this field:

* [Reddit](https://www.reddit.com/r/netsec)
* Twitter (follow a bunch of industry people)
* Blogs (perhaps even mine...)
* Books (my favorites in the resources section)
* Courses
* Attend Conferences (Network! Ask people what they're doing!)
* Watch Conference Videos
* Hands on Exercises

Everyone has a different learning style, you'll have to learn what works for
you.  I learn best by doing (hands-on) and somewhat by reading.  Videos are just
inspiration for me to look more into something.  Twitter and Reddit are the
starting grounds to find all the other resources.

I see an innate passion for this field in most of the successful people I know.
Many of us would do this even if we weren't paid (and do some of it in our spare
time anyway).  You don't have to spend every waking moment working, but you do
have to keep moving forward or get left behind.

## Understanding the Underlying System ##

To identify, understand, and exploit security vulnerabilities, you have to
understand the underlying system.  I've seen "penetration testers" who don't
know that paths on Linux/Unix systems start with and use `/` as the path
separator.  Watching someone try to exploit a potential
[LFI](https://www.owasp.org/index.php/Testing_for_Local_File_Inclusion) with
`\etc\passwd` is just painful.  (Hint: it doesn't work.)

If you're attacking web applications, you should at least have some understanding
of:

- The HTTP Protocol
- The Same Origin Policy
- The programming language used
- The operating system underneath

For non-web networked applications:

- A basic understanding of TCP/IP (or UDP/IP, if applicable)
- Basic computer architecture (stack, heap, etc.)
- Language used for implementation

You don't have to know everything about every layer, but each item you don't
know is either something you'll potentially miss, or something that will cost
you time.  You'll learn more as you develop your skills, but there's some
fundamentals that will help you get started:

- Learn at least one interpreted and one compiled programming language.
  - Python and ruby are a good choice for interpreted languages, as most
    security tools are written in one of those, so you can modify & create your
    own tools when needed.
  - C is the classic language for demonstrating memory corruption
    vulnerabilities, and doesn't hide a lot of the underlying system, so a good
    choice for a compiled language.
- Know basic use of both Linux and Windows.  Basic use includes:
  - Network configuration
  - Command line basics
  - How services are run
- Learn a bit about x86/x86-64 architecture.
  - What are pointers?
  - What is the stack and the heap?
  - What are registers?

You don't have to have a full CS degree (but it certainly wouldn't hurt), but if
you don't understand how developers do their work, you'll have a much harder
time looking for and exploiting vulnerabilities.

## The CIA Triad ##

To understand security at all, you should understand the CIA triad.  This has
nothing to do with the American intelligence agency, but everything to do with 3
pillars of information security: **Confidentiality**, **Integrity**, and
**Availability.**

Confidentiality refers to allowing only authorized access to data.  For example,
preventing access to someone else's email falls into confidentiality.  This idea
has strong parallels to the notion of privacy.  Encryption is often used (and
misused) in the pursuit of confidentiality.
[Heartbleed](http://heartbleed.com/) is an example of a well-known bug affecting
confidentiality.

Integrity refers to allowing only authorized changes to state.  This can be the
state of data (avoiding file tampering), the state of execution (avoiding remote
code execution), or some combination.  Most of the "exciting" vulnerabilities in
information security impact integrity.
[GHOST](https://blog.qualys.com/laws-of-vulnerabilities/2015/01/27/the-ghost-vulnerability)
is an example of a well-known bug affecting integrity.

Availability is, perhaps, the easiest concept to understand.  This refers to the
ability of a service to be access by legitimate users when they want to access
it.  (And probably also as the speed they'd like.)

These 3 concepts are the main areas of concern for security engineers.

## Understanding Vulnerabilities ##

There are many ways to categorize vulnerabilities, so I won't try to list them
all, but find some and understand how they work.  The
[OWASP Top 10](https://github.com/OWASP/Top10/blob/master/2013/OWASP%20Top%2010%20-%202013.pdf)
is a good start for web vulnerabilities.  The [Modern Binary
Exploitation](https://github.com/RPISEC/mbe) course from RPISEC is a good choice
for understanding "Binary Exploitation".

It's really valuable to distinguish a bug from a vulnerability.  Most
vulnerabilities are bugs, most bugs are not vulnerabilities.  Bugs are
accidentally-introduced misbehavior in software.  Vulnerabilities are ways to
gain access to a higher (or different) privilege level in an unintended fashion.
Generally, a bug must violate one of the 3 pillars of the CIA triad to be
classified as a vulnerability.  (Though this is often subjective, see [systemd
bug].)

## Doing Security ##

At some point, it stops being about what you know and starts being about what
you can do.  Knowing things is useful in being able to do, but merely reciting
facts is not very useful in actual offensive security.  Getting hands-on
experience is critical, and this is one field where you need to be careful how
to do it.  *Please remember that, however you choose to practice, you should
stay legal and observe all applicable laws.*

There's a number of different options here that build relevant skills:

* Formal classes with hands-on components
* CTFs (please note that most CTF challenges have little resemblence to actual
  security work)
* Wargames (see CTFs, but some are closer)
* Lab work
* Bug bounties

Of these, lab work is the most relevant to me, but also the one requiring the
most time investment to setup.  Typically, a lab will involve setting up one or
more practices machines with known-vulnerable software (though feel free to progress to
finding unknown issues).  I'll have a follow-up post with information on
building an offensive security practice lab.

Bug bounties are a good option, but to a beginner, they'll be very daunting
because much of the low-hanging fruit will be gone, and there should be no known
vulnerabilities to practice on.  Getting into bug bounties without any prior
experience at all is likely to only teach frustration and anger.

## Resources ##

There are some suggested resources for getting started in Offensive Security.
I'll try to maintain them if I receive suggestions from other members of the
community.

### Web Resources ###

* Reddit
  * [/r/netsec](https://www.reddit.com/r/netsec)
  * [/r/ReverseEngineering](https://www.reddit.com/r/ReverseEngineering/)
* [OWASP Testing Guide](https://www.owasp.org/index.php/OWASP_Testing_Guide_v4_Table_of_Contents)
* [LiveOverflow on YouTube](https://www.youtube.com/channel/UClcE-kVhqyiHCcjYwcpfj9w)

### Books ###

### Courses ###

* [Penetration Testing with Kali Linux](https://www.kali.org/penetration-testing-with-kali-linux/)
* SANS
    * [SEC560: Network Penetration Testing and Ethical Hacking](https://www.sans.org/course/network-penetration-testing-ethical-hacking)
    * [SEC542: Web App Penetration Testing and Ethical Hacking](https://www.sans.org/course/web-app-penetration-testing-ethical-hacking)
