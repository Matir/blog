---
layout: post
title: "Announcement: PwnableWeb Released"
date: 2014-05-09 00:11:58 +0000
permalink: /2014/05/09/announcement-pwnableweb-released/
category: Security
tags:
  - PwnableWeb
  - CTF
  - Security
---
In addition to my primary interest in the technical aspects of information security, I'm also a big fan of wargames & CTFs as educational tools, so a while back, I decided I wanted to build a web-based wargame and CTF scoreboard system.  Today I am releasing the results of that, dubbed **PwnableWeb**, under the Apache 2.0 License.  It includes web-based wargame-style challenges and an accompanying scoreboard.

###The Framework
Each vulnerable site is built on top of a small framework that provides common functionality, and also provides a framework for building a client for interactive exploitation.  (It provides a target to exploit XSS and XSRF against.)

The current framework is written in Python, using Flask and SQLAlchemy for speed of development.  The vulnerable apps so far run just fine with a sqlite DB, but I usually use MySQL.  This isn't for load, but because SQLi is more interesting against the sort of DBs that are commonly used in the "real world".

###The Games
Currently, there are 2 games with a total of about a dozen vulnerabilities.  One is a shopping cart system and the other is a microblogging platform.  I do have plans to add a couple of more games in the near future, and will probably include new platforms (PHP being the top priority) to demonstrate new classes of vulnerabilities (LFI/RFI, serialize, preg '/e', etc.) and provide variety.

Obviously, to a certain extent, open sourcing these games makes them less useful for a "real" CTF: players can easily have seen these before and become aware of where the vulnerabilities are.  (And what the default flags are.)  However, I believe they are still useful for practice for CTF teams, for use in educating developers, or even for internal CTFs where people are unlikely to have seen this before or you just don't care.

GitHub repository: [https://github.com/Matir/pwnableweb](https://github.com/Matir/pwnableweb)

###The Scoreboard
The scoreboard resides in its own git repository because, though released as part of the PwnableWeb "suite", it is completely independent and is designed to be usable for any CTF scoreboard.  Currrent features include:

- Unlockable hints
- Locked/unlocked question state
- Support for Teams and Individuals

Future development priorities:

- File management for pwnables
- Real-time updates via push messaging

GitHub repository: [https://github.com/Matir/pwnableweb-scoreboard](https://github.com/Matir/pwnableweb-scoreboard)

###Notes on Running It
**Do not run these on a server shared with anything else.**  The vulnerable applications contain, well, vulnerabilities.  Some of these vulnerabilities may lead to RCE as the user running the application.  Run them in a dedicated VM or physical machine.  In the near future, I plan to provide a VM image for super-easy-setup.

###Conclusion/Contributing
There will be quite a bit of polish being applied to the current release over the next few days; it's admittedly very raw and could use better documentation and configuration examples, but I'm happy to be able to release it at this point.

If you end up using this for something, I'd love to hear about it, and hear about your experience using it.  I'm also quite open to pull requests, suggestions, and feedback.
