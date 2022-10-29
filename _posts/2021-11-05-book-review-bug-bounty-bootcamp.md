---
layout: post
title: "Book Review: Bug Bounty Bootcamp"
category: Security
date: 2021-11-05
tags:
  - Book Review
---

*Bug Bounty Bootcamp* ([Amazon](https://amzn.to/3BOzpMq),
[No Starch Press](https://nostarch.com/bug-bounty-bootcamp))
by Vickie Li is one of No Starch Press's newest offerings in the security space.
The alliterative title is also the best three word summary I could possibly
offer of the book -- it is clearly focused on getting the reader into a position
to participate in Bug Bounties from the first page to the last.  This
differentiates this book well against other web security books, despite covering
many of the same vulnerabilities.

<!--more-->

**Note**: I was provided an early access copy of *Bug Bounty Bootcamp* by the
publisher for review, but they had no editorial input.  All of the opinions in
this review are my own.

The first couple of chapters provide an introduction to the Bug Bounty space,
helping the reader to understand the role of bounties in the overall security
program of a company, selecting a bounty to participate in, and how the programs
are managed in different situations.  It also does a fairly good job of setting
expectations for new bounty participants, but I think it might be a little bit
on the optimistic side for some that are newer to the space.

The second part of the book covers some foundational knowledge and tooling
setup, as well as performing reconnaissance on the target environment.  The
recon section feels a little light because there are so many situational
approaches out there, but for a beginner, it will be a good start.  As one gets
more experienced, you will need to recognize that there are a lot of other
sources of information and incorporating them into your methodology will improve
your coverage.  (And hopefully also your findings.)

In the third part, Vickie describes a wide of vulnerability types that may be
found in common web applications.  Obviously, it is not possible to cover every
vulnerability and edge case, but the vulnerabilities described cover the vast
majority of findings that I have found or seen reported in web applications.
16 Chapters cover a wide variety of vulnerability classes -- so many that it may
feel overwhelming to newcomers, so I'd suggest picking a subset of classes to
start testing for at first.  This will give you time to get comfortable with the
process and tooling for testing.

Chapter 17, which covers logic errors and broken access control, in particular,
is one that I think all web developers should read.  (In addition, of course, to
bug bounty hunters.)  These bugs are pervasive and essentially impossible for
better frameworks, web application firewalls, or automated tooling to mitigate
because they require an understanding of the underlying business logic in
addition to the technical understanding of vulnerability classes.

The fourth, and final, part of this book collects what Vickie refers to as
"Expert Techniques".  While they are an extension of other techniques to cover
more surface, I think these can be applied even by those with less experience in
the field.  In particular, covering API and Android apps is a rather natural
extension of web security, as most of these are just HTTP APIs with a nice
facade on them.  Fuzzing is a bit more advanced and further afield, but she
provides a nice introduction to them in the final chapter of the book.  These
chapters do have a bit of a "supplemental" feel to them, and those brand new to
security may wish to return to them after gaining some experience with the other
vulnerabilities covered and the tooling involved.

I do recommend that more individuals looking to have success in bug bounty
programs consider understanding APIs and mobile applications, as these attack
surfaces seem to be far less covered, leading to more opportunities to be the
first discoverer of a bug.  It's very nice to see that these are covered here,
as bug bounty coverage is often "web only".

This book does bear some similarities to No Starch's own
[*Real-World Bug Hunting*](https://amzn.to/3bN7jq1), but it also stands its own
ground.  *Real-World Bug Hunting* focuses almost entirely just on the
vulnerability classes, while *Bug Bounty Bootcamp* has a lot more content about
automating reconnaisance, integrating a lifecycle for ongoing testing of the
same properties, and supplementing your tooling with your own scripting and
development.  If you have the time, I can handily recommend reading both of
these resources.  If you're only going to read one, and your predominant
interest is success in Bug Bounties, I think *Bug Bounty Bootcamp* will do a
better job of preparing you for that.

Readers who are interested in full-time roles doing security assessment as
opposed to just bug bounties -- such as penetration testers or application
security engineers -- may still find this book useful, but will want to
supplement their approach with more traditional resources.  A good compliment
might be
[*The Web Application Hacker's Handbook*](https://amzn.to/3CSmslM).  This is not
a negative of the book (as it never *claimed* to be anything beyond the bug
bounty space) but is still something for readers to be aware of depending on
their personal goals and roles.

*Bug Bounty Bootcamp* is a great resource for those who want to participate in
Bug Bounties because it not only teaches you about the technical aspects, but
helps you develop a methodology and sustain your testing.  Some technology
knowledge is assumed, but it does a solid job of describing the relevant
vulnerability types from first principles, so it can be a strong resource for
those new to the security space.  The writing style is clear and to the point.
