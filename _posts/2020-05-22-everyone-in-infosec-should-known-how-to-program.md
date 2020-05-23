---
layout: post
title: "Everyone in InfoSec Should Know How to Program"
category: Security
date: 2020-05-22
tags:
  - Security
---

Okay, I'm not going to lie, the title was a bit of clickbait.  I don't believe
that everyone in InfoSec really needs to know how to program, just *almost*
everyone.  Now, before my fellow practitioners jump on me, saying they can do
their job *just fine* without programming, I'd appreciate you hearing me out.

So, how'd I get on this?  Well, a thread on a private Slack discussing whether
Red Team operators should know how to program, followed by people on Reddit
asking if they should know how to program.  I thought I'd share my views in a
concrete (and longer) format here.

### Computers are Useless without Programs ###

I realize that it sounds idomatic, but computers don't do anything without
programs.  Programs are what gives a computer the ability to, well, be useful.
So I think we can all agree that information security, as an industry, is based
entirely around software.

I submit that knowing how to program makes most roles more effective merely by
having a better understanding of how software works.  Understanding I/O, network
connectivity, etc., at the application layer will help professionals do a better
job of understanding how software affects their role.

That being said, this is probably not reason enough to learn to program.

### Learning to Program Opens Doors ###

I suppose this point can be summarized as "more skills makes you more
employable", which is probably (again) idiomatic, but it's probably worth
considering.  There are roles and organizations that will expect you to be able
to program as part of the core expectations.

For example, if you currently work in the SoC, and you want to work on
building/refining the tools used in the SoC, you'll need to program.

Alternatively, if you want to move laterally to certain roles, those roles will
require programming -- application security, tool development, etc.

### You Will Be More Efficient ### 

There are so many times where I could have done something manually, but ended up
writing a program of some sort to do it instead.  Maybe you have a range of IPs
and need to check which of them are running a particular webserver, or you want
to combine several CSVs based on one or two fields on them.  Maybe you just want
to automate some daily task.

As a Red Teamer, I often write scripts to accomplish a variety of tasks:

- Check a bunch of servers for a Vulnerability/Misconfiguration
- Proof of Concept to Exploit a Vulnerability
- Analyze large sets of data
- Write custom implants ("Remote Access Toolkits")
- Modify tools to limit scope

On the blue side, I know people who write programs to:

- Analyze log files when Splunk, etc. just won't do
- Analyze large PCAPs
- Convert configurations between formats
- Provide web interfaces to tools that lack them

### How much do you need to know? ###

Well, technically none, depending on your role.  But if you've read this far, I
hope you're convinced of the benefits.  I'm not suggesting everyone needs to be
a full-on software engineer or be coding every day, but knowing something about
programming is useful.

I suggest learning a language like Python or Ruby, since they have REPLs, a
"read-eval-print loop".  These provide an interactive prompt where you can run
statements and see the responses immediately.  Python seems to be more commonly
used for InfoSec tooling, but they both are good options to get things done.

I would focus on file and network operations, and not so much on complicated
algorithms or data structures.  While those can be useful, standard libraries
tend to have common algorithms (searching, sorting, etc.) well-covered.  Having
a sensible data structure makes code more readable, but there's not often a need
for "low level" structures in a high level language.

### Have I Convinced You? ###

Hopefully I've convinced you.  If you want to learn programming with a
security-specific slant, I can highly recommend some books from No Starch Press:

- [Black Hat Go](https://nostarch.com/blackhatgo)
- [Black Hat Python](https://nostarch.com/blackhatpython)
- [Gray Hat Python](https://nostarch.com/ghpython.htm)
- [Gray Hat C#](https://nostarch.com/grayhatcsharp)
