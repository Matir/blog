---
layout: post
title: "Security: Not a Binary State"
date: 2014-09-05 00:03:24 +0000
permalink: /blog/security-not-a-binary-state/
category: Security
tags: Security
---
I've been spending a fair amount of time on [Security StackExchange](https://security.stackexchange.com) lately, mostly looking for inspiration for research and blogging, but also answering a question every now and then.  One trend I've noticed is asking questions of the form "Is *security practice X* secure?"

This is asked as a yes/no question, but security isn't a binary state.  There is no "absolutely secure."  Security is a spectrum, and it really depends on what you're worried about, which is where threat modeling comes in.  Both users and service providers need to consider their risks and decide what's important to them.

**Users**

Most internet users will never be specifically targeted by an attacker.  Their concerns will (should) include:

- Run-of-the-mill malware
- Phishing
- Security on public hotspots
- Password management

For these users, maintaining a patched system, being aware of phishing, using a VPN on public hotspots, and maybe using an anti-virus or anti-malware program will generally protect against the threats they're subject to.  Of course, education is still important, as if they run random programs downloaded from the internet, malware will still make its way in.

Other users might have a more determined adversary.  Those with access to financial systems, valuable data, or other desirable access may end up being targeted.  Spearphishing becomes an issue.  Depending on what you do, you might even find yourself subject to the ire of well-funded state attackers.  What is adequately secure for a "normal" user is woefully inadequate for these users.

**Service Providers**

I'd originally only intended to talk about providers of Internet services, but given the continuing tendency of businesses to place their infrastructure online, I think all businesses interacting with customers fall into this category.

Service providers have a responsibility to two kinds of data: their data, and their user's data.  For their data, they are essentially a user as above.  The service provider should perform their own threat modeling, decide what risks are and are not acceptable to them, and then act to secure their data against the risks they are worried about.

User data, on the other hand, is sacred.  While no business can protect against every possible adversary, they should consider the trust users place in them and try to protect the data as their users would want it protected.  While the provider might be willing to roll the dice on, say, their corporate email, they should consider if that data can be used to compromise user data.  (Nearly universally, the answer to that question is "yes.")

We've had a recent series of Point-of-Sale data breaches, including [Target](https://corporate.target.com/about/payment-card-issue.aspx) and [Home Depot](http://krebsonsecurity.com/2014/09/banks-credit-card-breach-at-home-depot/).  I'm disappointed that, so far, these haven't seemed to hurt the retailers very much.  Retailers will only take adequate measures to protect themselves when it becomes obvious that the consequences of a data breach will be massive.  If consequences of violating PCI actually had teeth (e.g., you can't accept credit cards anymore for some period of time until you can be re-certified, like 6 months) and customers moved elsewhere, maybe the businesses would get a bit proactive.

**Conclusion**

That's enough ranting for now, but I wanted to get one main point across: It's important to remember that you can never be "secure."  You can only be "secure enough" to defend against some set of adversaries and threats.  Anything else is just wishful thinking.
