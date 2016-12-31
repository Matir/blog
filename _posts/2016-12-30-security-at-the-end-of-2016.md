---
layout: post
title: "Security at the End of 2016"
category: Security
date: 2016-12-31
tags:
  - Security
  - 2016
---
Well, 2016 is just about at an end, and what a year it has been.  I'm not going
to delve into politics, though that will arguably be how the history books will
remember this year, but I want to take a look back at a few of the big security
headlines of the year, and then make some completely wildass prognostications
about information security in 2017.

### Bad News of 2016

[Yahoo! reported over 1 billion accounts](https://en.wikipedia.org/wiki/Yahoo!_data_breaches)
were stolen by unknown attackers.  Though the breaches occurred in 2013 and
2014, they weren't publicly reported until the tail end of this year.

The US Government has claimed that [Russians interfered with the US
election](http://arstechnica.com/security/2016/12/did-russia-tamper-with-the-2016-election-bitter-debate-likely-to-rage-on/)
by hacking the political parties, voter registration, etc.  Whether or not it
was done by the Russian government or so-called "lone wolves" is still not
clear from the information that's been released, but was is clear is that there
was a data breach in at least the DNC during a major election.

Speaking of the FBI and DHS reporting on hacking, [they themselves were
breached](https://www.wired.com/2016/02/hack-brief-fbi-and-dhs-are-targets-in-employee-info-hack/)
near the beginning of the year.  I'm glad we have them to investigate and report
on data breaches and compromises in the US.  Peraps they should look at their
own networks first.

In continuing government insecurity, the Internal Revenue Service
[lost data on 700,000
taxpayers](https://gizmodo.com/over-700-000-people-got-screwed-in-last-years-irs-data-1761565531).
Good thing they don't deal with anything particularly sensitive, right?

I could go on about data breaches --
[LinkedIn](http://arstechnica.com/tech-policy/2016/10/linkedin-says-hacking-suspect-is-tied-to-breach-that-stole-117m-passwords/),
[the FDIC](https://www.washingtonpost.com/news/powerpost/wp/2016/04/11/inadvertent-cyber-breach-hits-44000-fdic-customers/?utm_term=.ceb6bd49792b), 
[Verizon Enterprise](https://krebsonsecurity.com/2016/03/crooks-steal-sell-verizon-enterprise-customer-data/),
and on and on and on.

The most unusual event of 2016 was the formation of the [Mirai
botnet](https://en.wikipedia.org/wiki/Mirai_(malware)), a massive botnet of
Internet of Things devices, which was used to DoS security blogger Brian Krebs,
Amazon's AWS network, and other networks, resulting in significant disruptions
to major services, including everyday services like Netflix.

### What 2017 Will Bring

I believe 2017 will bring increasing complexity to our applications and
networks, making life even harder for security professionals.  We'll have more
platforms, more IoT, more devices, and more breaches.

Security is a hard field to stay ahead of, no matter how hard you work at it.  I
try to read every article, every paper, every book I can get my hands on just to
stay in the game, let alone get to the top.

Take a look at Cross-Site Scripting.  A few years ago, we just had to worry
about the XSS bug itself and how it would affect the origin containing the bug.
Today, we have the XSS bug and mitigations from CSP (several versions), we have CORS allowing bugs
to span origins, we have XSS stored in LocalStorage, and we have CSP bypasses at
every corner.  Who knows what 2017 will bring in just that narrow space?

I'm hoping 2017 will bring more interesting research, more open collaboration,
and more quality tools and work.  I'm particularly hoping that I'll be able to
bring some interesting work to light in 2017 -- and maybe some fun bugs along
the way.

To all my fellow hackers: happy new year!
