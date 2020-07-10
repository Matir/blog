---
layout: post
title: "Comparing 3 Great Web Security Books"
category: Security
tags:
  - Web Security
  - Book Review
date: 2020-07-10
---

I thought about using a clickbait title like "Is this the best web security
book?", but I just couldn't do that to you all.  Instead, I want to compare and
contrast 3 books, all of which I consider great books about web security.  I
won't declare any single book "the best" because that's too subjective.  Best
depends on where you're coming from and what you're trying to achieve.

The 3 books I'm taking a look at are:

- [Real-World Bug Hunting: A Field Guide to Web
  Hacking](https://amzn.to/2ZUg4bK)
- [The Web Application Hacker's Handbook: Finding and Exploiting Security
  Flaws](https://amzn.to/2ZVZojX)
- [The Tangled Web: A Guide to Securing Modern Web
  Applications](https://amzn.to/2W5KQ05)

<!--more-->

## Real-World Bug Hunting: A Field Guide to Web Hacking ##
{:.clear}

[![Real World Bug Hunting](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=1593278616&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US){:.amzimg}](https://www.amazon.com/Real-World-Bug-Hunting-Field-Hacking/dp/1593278616/ref=as_li_ss_il?dchild=1&keywords=real+world+bug+hunting&qid=1594400777&sr=8-1&linkCode=li2&tag=systemovecom-20&linkId=6f607bee75c5a0d5fa37abf12d56ac88&language=en_US){:.left}

- Author: Peter Yaworksi
- Published: 2019 by No Starch Press
- 264 Pages
- [Amazon](https://amzn.to/2ZUg4bK)
- [No Starch Press](https://nostarch.com/bughunting)

Real-World Bug Hunting is the most recent of the books in this group, and it
shows.  It covers up to date vulnerabilities *and mitigations*, such as
the `samesite` attribute for cookies, Content Security Policy, and more.  As its
name suggests, it has a clear focus on finding bugs, and goes into just enough
detail about each bug class to help you understand the underlying risks posed by
a vulnerability.

The book covers the following vulnerability classes:

- Open Redirect
- HTTP Parameter Pollution
- Cross-Site Request Forgery (CSRF)
- HTML Injection
- HTTP Response Splitting
- Cross-Site Scripting (XSS)
- SQL Injection
- Server Side Request Forgery (SSRF)
- XML External Entity (XXE)
- Remote Code Execution
- Memory Corruption (lightly covered)
- Subdomain Takeover
- Race Conditions
- Insecure Direct Object References (IDOR)
- OAUTH Vulnerabilities
- Logic Bugs

It definitely has a "bug bounty" focus, which has both pros and cons.  On the
plus side, it's directly focused on finding and exploiting bugs and is able to
use disclosed vulnerabilities from bug bounties as real-world examples of how
these bug classes apply.  On the other hand, it has almost no discussion of how
to address the bugs from an engineering point of view, and it doesn't do a great
job of going beyond a Proof of Concept stage to real exploitation that an
attacker might do.  (For the developer side, you might want to consider another
No Starch publication, [Web Security for Developers](https://amzn.to/3gPk8kq).)

Chapters are well thought-out and stand alone if you just want familiarity with
some of the topics.  Examples are incredibly well documented and understandable,
and include just enough to get you going without extraneous code/text.

While this book is an obvious win for those with an interest in doing Bug
Bounties (e.g., HackerOne or Bugcrowd), I would also recommend this book to new
Penetration Testers or Red Teamers who don't have experience with web security
or haven't kept up with developments.  It's a great way to get bootstrapped, and
it's quite well written, so it's also an easy read.  It's not overly long either
and lends itself to easily doing a chapter at a time and reading over a couple
of weeks if you don't have much time right now.

## The Web Application Hacker's Handbook: Finding and Exploting Security Flaws ##
{:.clear}

[![The Web Application Hacker's Handbook](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=1118026470&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US){:.amzimg}](https://www.amazon.com/Web-Application-Hackers-Handbook-Exploiting/dp/1118026470/ref=as_li_ss_il?crid=IZHDMYMQ0PHO&dchild=1&keywords=web+application+hackers+handbook&qid=1594400874&sprefix=web+applicat,aps,235&sr=8-2&linkCode=li2&tag=systemovecom-20&linkId=cd33f1ae591e3814787d748285b58292&language=en_US){:.left}

- Authors: Dafydd Stuttard, Marcus Pinto
- Published: 2011 by Wiley
- 912 Pages
- [Amazon](https://amzn.to/2ZVZojX)

This is an older book, but so many of the fundamental issues haven't changed.
Cross-site scripting and cross-site request forgery are still some of the most
common web vulnerabilities, remaining in the OWASP Top 10 throughout this time
period.

This book is an absolute beast of a reference on web security.  It took me
several attempts to actually (eventually) make my way through the entire thing.
It goes into a great deal of detail about each topic, including the fundamentals
of web security and the vulnerabilities that arise from mistakes in design or
implementation of web applications.

Because Dafydd is the author of [Burp Suite](https://portswigger.net/burp), the
premiere web application testing proxy, the examples given in the book rely
heavily on the functionality and tooling provided by Burp.  Many of the
features/tools are available in the Burp Community Edition, but not all of them.
(Though, if you're serious about web security, you really should get a Burp
Professional license -- it's totally worth it.)

As opposed to the bug class oriented approach taken by *Real World Bug Hunting*,
*The Web Application Hacker's Handbook* focuses more on the component-wise
nature of web applications and the common attacks on each area.  It covers many
of the same bug classes, but looks at it by application component where they're
likely to occur instead.  The general areas considered include:

- Web Application Security Basics
- Enumeration/Mapping
- Client-Side Controls
- Authentication
- Session Management
- Access Control
- Data Storage
- Backends
- Application Logic Flaws
- Cross Site Scripting
- Attacking Users
- Automating Attacks
- Architecture Problems
- Underlying Application Server Bugs
- Source Review
- Web Hacking Methodologies

*The Web Application Hacker's Handbook* is the most in-depth web security book
I've been able to find.  Unfortunately, it's now 9 years old, and a lot has
changed in the web space.  While most, if not all, of the vulnerabilities still
exist, there may be many mitigations that are not discussed in the book.  You'll
probably need to do something to get from this book to get fully up to speed,
but on the other hand, you'll have a very deep understanding of the ways in
which web applications can go wrong.

Additionally, if you want to become a Burp Suite power user, going through this
book will give you a big boost up due to the emphasis on using Burp Suite to its
fullest.

## The Tangled Web: A Guide to Securing Modern Web Applications ##
{:.clear}

[![The Tangled Web](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=1593273886&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US){:.amzimg}](https://www.amazon.com/Tangled-Web-Securing-Modern-Applications/dp/1593273886/ref=as_li_ss_il?dchild=1&keywords=the+tangled+web&qid=1594400948&sr=8-3&linkCode=li2&tag=systemovecom-20&linkId=60cb7b5c90e0d6bf2b325a9d344cd582&language=en_US){:.left}

- Author: Michal Zalewski
- Published: 2011 by No Starch Press
- 320 Pages
- [Amazon](https://amzn.to/2W5KQ05)
- [No Starch Press](https://nostarch.com/tangledweb)

(Full disclosure: I formerly worked with Michal on the product security team at
Google.  I'd first read the book prior to that, and it in no way affects my
ability to recommend this as a great book.)

I almost didn't include this book in comparison to the other two because it's so
different.  Rather than focusing strictly on the common classes of web bugs,
this focuses on how the web works and how the various vulnerabilities came to
be, and how new vulnerabilites might occur.  It does this by examining web
servers, web applications, and web browsers, and their interactions (which turn
out to be quite complex if you're just familiar with the basics of HTTP).

Instead of vulnerability classes, it focuses on web technologies:

- HTTP
- HTML
- CSS
- JavaScript
- Same Origin Policy
- Security Boundaries

If you're looking to take a new look at web vulnerabilities and already have a
fundamental understanding of the basics, this is a great opportunity to expand
your understanding.  While it does talk about the common vulnerabilities, it
also exposes strange bug classes, like vulnerabilities only exploitable on a
single browser due to weird parsing bugs, or the confusion in parsing the same
document between a client and a server.

After all, the reason Cross-Site Scripting exists is that something the server
understood as "data" is interpreted by the browser as "code" to be executed.
HTTP Response Splitting is also a vulnerability brought about by mixing data and
metadata (headers) together.

This book is a fascinating read and has wonderful examples, and I feel certain
that almost everything will discover something they didn't already know about
web security.  Even though *The Tangled Web* is a little bit old, it's worth
reading to get an understanding of the bad things that can happen and the
strange edge cases you might never have considered before.

One of my favorite parts of the book is the presence of a "cheatsheet" in each
chapter that summarizes the concepts and how to apply them.  This makes the book
both a good introduction and a good reference, which is rare to find in the same
publication.

It's worth noting that the book is a little bit less of an *easy* read than I
would like.  In some places it seems to jump around and lacks a clear path
forward.  Another downside that is directly related to the age of the book is
the number of examples that focus on Internet Explorer, which is obviously no
longer a significant concern on the Internet.

## So Which Book? ##
{:.clear}

Well, like I said earlier, I'm not going to declare a "best" book here.  If
you're completely new to web security or just looking to do bug bounties, I'd
suggest [*Real-World Bug Hunting*](#real-world-bug-hunting) as the easiest to
digest and most direct to those goals.  If you're looking for the most content
but still focusing on attacking applications, I'd go with the [*Web Application
Hacker's Handbook*](#the-web-application-hackers-handbook).  Finally, if you're
interested in the most esoteric edge cases, [*The Tangled Web*](#the-tangled-web)
is your goto, but it's more of a supplement to the others if you intend to do a
lot of web assessments.

Of course, I've read all three of the books, and I've learned something from all
of them.  If you have the time and patience (as well as the desire to get much
deeper into web security), I think it would be worth your time to read more than
one, possibly even all of them, though maybe I'm just an outlier in that case.
