---
layout: post
title: "Blue Team Player's Guide for Pros vs Joes CTF"
date: 2015-08-15 19:15:36 +0000
permalink: /2015/08/15/blue-team-players-guide-for-pros-vs-joes-ctf/
category: Security
tags:
  - CTF
  - BSides
---
I've played in Dichotomy's [Pros v Joes](http://www.prosversusjoes.net/) CTF for
the past 3 years -- which, I'm told, makes me the only player to have done so.
It's an incredible CTF and dramatically different from any other that I've ever
played.  Dichotomy and I were having lunch at DEF CON when he said "You know
what would be cool?  A blue team player's guide."  So, I give to you, the blue
team player's guide to the Pros v Joes CTF.

### Basics ###

First, a quick review of the basics: PvJ is a 2-day long CTF.  On day one, blue
teams operate in a strictly defensive role.  Red cell will be coming after you
relentlessly, and it's your job to keep them out. On day two, things take a turn for
the red, with blue teams both responsible for defending their network, but also
given the opportunity to attack the networks of the other blue teams.  Offense
is fun, but do keep in mind that you need some defense on day two.  Your network
will have been reset, so you'll need to re-harden all your systems!

Scoring is based on several factors.  As of 2015, the first day score was based
on flags (gain points for finding your own "integrity" flags, lose points for
having flags stolen), service uptime (lose points for downtime), tickets (lose
points for failing to complete required tasks in the environment), and beacons
(lose points for red cell leaving "beacons" that phone home on your system,
indicating ongoing compromise).  Day two scoring is similar, but now you can
earn points by stealing flags from other teams and placing your own beacons on
their systems to phone home.

Make sure you read the rules when you play -- each year they're a little
different, and things that have been done before may not fit within the rules --
or may not be to your advantage anymore!

### The Environment ###

Before I start talking strategy, let's talk a little bit about the environment
and what to expect.  Of course, Dichotomy may have new tricks up his sleeve at
any time, so you have to assume almost everything below will change.

Connecting to the environment requires connecting to an OpenVPN network that
provides a route to your environment as well as all of the other teams -- think
of it as a self-contained mini-internet.  Within this environment is a large
vCenter deployment, containing all of the blue team environments.  You'll get
access to the vCenter server, but only to your hosts of course.

Each team will have a /24 network to protect, containing a number of hosts.  In
2015, there were a dozen or so hosts per network.  All blue team networks
contain the same systems, providing the same services, but they will have
different flags and credentials.  In front of your /24 is a Cisco ASA firewall.
Yes, you get access to configure it, so it's good to have someone on your team
who has seen one before.  (My team found this out the hard way this year.)

While the exact hosts are likely to change each year, I feel pretty confident
that many of the core systems are unlikely to be dramatically different.  Some
of the systems that have consistently been present include:

* A Windows Server 2008 acting as a Domain Controller
* Several Linux servers in multiple flavors: Ubuntu, CentOS, SuSE
* A number of Windows XP machines

### Responsibilties as a Blue Team Member ###

This is intended as a learning experience, so nobody expects you to show up
knowing everything about **attack** and **defense** on **every** system.  That's
just not realistic.  But you should show up prepared to play, and there's
several things involved in being prepared:

1. Make sure you introduce yourself to your team mates via the team mailing
   list.  It's good to know who's who, what their skill sets are, and what
   they're hoping to get out of the CTF.  (And yes, "have a good time" is a
   perfectly acceptable objective.)
2. Have your machine set up in advance.  Obviously, you're going to need a
   laptop to play in this CTF.  It doesn't need to be the fastest or newest
   machine, but you should have a minimum toolkit:
    * OpenVPN to connect to the environment, configured and tested.
    * VMWare vSphere Client to connect to the vCenter host.  (Windows only, so
     this might also call for a VM if your host OS is not Windows.)
    * An RDP Client of some sort is useful for the Windows machines in the
     environment.
    * Tools to map out your network, such as nmap, OpenVAS, or similar.
    * Attack tools for the 2nd day: Metasploit is always popular.  If you're not
     familiar with metasploit, consider also installing Armitage, a popular GUI
     front end.
   I usually run Kali Linux on the bare metal and have a Windows VM just for
   vSphere client.  Make sure you run OpenVPN on your *host* OS so that traffic
   from both the host and guest gets routed to the environment properly.
3. Learn a few basics in advance.  At a minimum, know how to connect both to
   Windows and Linux systems.  Never used ssh before?  Learn how in advance.
   There's a reading list at the bottom of this article with resources that will
   help you familiarize yourself with many of the aspects involved before the
   day of the event.
4. You don't have to sit there at the table the entire day both days, but you
   should plan for the majority of the time.  If you want to go see a talk, that
   works, but let somebody know and make sure you're not walking off with the
   only copy of a password.

### Strategy ###

I could probably find a Sun Tzu quote that fits here (that is the security
industry tradition, after all) but really, they're getting a bit over used.
What is important is realizing that you're part of a team and that you'll either
succeed as a team or fail.  Whether you fail as a team or as a bunch of
individuals with no coordination depends on a lot of things, but if you're not
working together, you can be certain of failure.

With so many systems, there's a lot of work to be done.  With Red Team on the
advance, there's a lot of work to be done quickly.  You need to make sure that
*quickly* does not turn into *chaotically*.  I suggest first identifying all of
the basic hardening steps to be taken, then splitting the work among the team,
making sure each task is "owned" by a team member.  Some of the tasks might
include:

1. Configure the ASA firewall to only allow in SSH, RDP, and the services you
   need for scoring purposes.  (Note that you're not allowed to add IP filtering
   against red cell, nor block beacons to the scoring server.)
2. Change the passwords on each system (divide this up so each individual only
   has 1-2 systems to handle) and document them.  (A Google spreadsheet works
   well here.)
3. Start an nmap scan of your entire network as a baseline. (Doing this from one
   of the hosts within the environment will be *much* faster than doing it from
   your laptop over the VPN.)
4. Start disabling unnecessary services.  (Again, responsibility for 1-2 systems
   per team member.)

Remember: document what you do, especially the passwords!

For the second day, I recommend a roughly 80/20 split of your team, switching
after the basic hardening is done.  That is, for the first hour or so, 80% of
your team should be hardening systems while 20% looks for the low-hanging fruit
on other team's networks.  This is a good opportunity to get an early foothold
before *they* have the chance to harden.  After the initial hardening (setup
ASA, change passwords, etc.), you want to devote more resources to the
offensive, but you still need some people looking after the home front.

Good communication is key throughout, but watch out how you handle it: you never
know who's listening.  One year we had an IRC channel where everyone connected
(over SSL of course!) for coordination so we would leak less information.

### Pro Tips ###

Some tips just didn't fit well into other parts of the guide, so I've compiled
them here.

* Changing all the passwords to one "standard" may be attractive, but it'll only
  take one keylogger from red cell to make you regret that decision.
* Consider disabling password-based auth on the linux machines entirely, and use
  SSH keys instead.
* The scoring bot uses usernames and passwords to log in to some services.
  Changing those passwords may have an adverse effect on your scoring.  Find
  other ways to lock down those accounts.
* Rotate roles, giving everyone a chance to go on both offense and defense.

### Recommended Reading ###

#### Hardening ####

* [NIST Windows Server 2008 STIG](https://web.nvd.nist.gov/view/ncp/repository/checklistDetail?id=228)
* [SANS Institute Linux Security Checklist](https://www.sans.org/media/score/checklists/linuxchecklist.pdf)
* [RHEL 6 Security Guide](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/pdf/Security_Guide/Red_Hat_Enterprise_Linux-6-Security_Guide-en-US.pdf)

#### Offensive Security ####

* [RTFM: Red Team Field Manual](http://amzn.to/1J7opH5)
* [The Hacker Playbook 2: Practical Guide to Penetration Testing](http://amzn.to/1UKI6N2)
* [Metasploit: The Penetration Tester's Guide](http://amzn.to/1gJX1rL)
* [Metasploit Unleashed](https://www.offensive-security.com/metasploit-unleashed/)
* [NMAP Reference Guide](https://nmap.org/book/man.html)

### Conclusion ###

The most important thing to remember is that you're there to learn and have fun.
It doesn't matter if you win or lose, so long as you got something out of it.
Three years straight, I've walked away from the table feeling like I got
*something* out of it.  I've met great people, had great fun, and learned a few
things along the way.  GL;HF!

