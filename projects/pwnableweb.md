---
layout: project
title: "PwnableWeb: Vulnerable Apps & Scoreboard for Teaching"
date: 2014-04-01
---

### The Framework
Each vulnerable site is built on top of a small framework that provides common functionality, and also provides a framework for building a client for interactive exploitation. (It provides a target to exploit XSS and XSRF against.)

The current framework is written in Python, using Flask and SQLAlchemy for speed of development. The vulnerable apps so far run just fine with a sqlite DB, but I usually use MySQL. This isn't for load, but because SQLi is more interesting against the sort of DBs that are commonly used in the "real world".

### The Games
Currently, there are 2 games with a total of about a dozen vulnerabilities. One is a shopping cart system and the other is a microblogging platform. I do have plans to add a couple of more games in the near future, and will probably include new platforms (PHP being the top priority) to demonstrate new classes of vulnerabilities (LFI/RFI, serialize, preg '/e', etc.) and provide variety.

Obviously, to a certain extent, open sourcing these games makes them less useful for a "real" CTF: players can easily have seen these before and become aware of where the vulnerabilities are. (And what the default flags are.) However, I believe they are still useful for practice for CTF teams, for use in educating developers, or even for internal CTFs where people are unlikely to have seen this before or you just don't care.

**GitHub repository: <https://github.com/Matir/pwnableweb>**

### The Scoreboard
The scoreboard resides in its own git repository because, though released as part of the PwnableWeb "suite", it is completely independent and is designed to be usable for any CTF scoreboard. Currrent features include:

* Unlockable hints
* Locked/unlocked question state
* Support for Teams and Individuals
* File management for pwnables

Future development priorities:

* Real-time updates via push messaging
* Automated Scoring Bots

**GitHub repository: <https://github.com/Matir/pwnableweb-scoreboard>**

### Notes on Running It
Do not run these on a server shared with anything else. The vulnerable applications contain, well, vulnerabilities. Some of these vulnerabilities may lead to RCE as the user running the application. Run them in a dedicated VM or physical machine. In the near future, I plan to provide a VM image for super-easy-setup.

### License/Contributing
PwnableWeb and the scoreboard are licensed under the Apache 2.0 license. If you'd like to contribute, feel free to send a pull request on Github or send me a patch!
