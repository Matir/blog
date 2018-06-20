---
layout: post
title: "Pros vs Joes CTF: The Evolution of Blue Teams"
category: Security
date: 2018-06-19
tags:
  - Security
  - CTF
  - PvJ
---

[Pros v Joes CTF](http://prosversusjoes.net/) is a CTF that holds a special
place in my heart.  Over the years, I've moved from playing in the 1st CTF as a
day-of pickup player (signing up at the conference) to a Blue Team Pro, to core
CTF staff.  It's been an exciting journey, and Red Teaming there is about the
only role I haven't held.  (Which is somewhat ironic given that my day job is a
red team lead.)  As Blue teams have just formed, and I'm not currently attached
to any single team, I wanted to share my thoughts on the evolution of Blue
teaming in this unique CTF.  In many ways, this will resemble the [Blue Team
player's guide](/2015/08/15/blue-team-players-guide-for-pros-vs-joes-ctf/) I
wrote about 3 years ago, but will be based on the evolution of the game and of
the industry itself.  That post remains relevant, and I encourage you to read it
as well.

## Basics ##

Let's start by a refresher of the basics, as they exist today.  The gameplay is
a two day game, with teams being completely "blue" (defensive) on the first day,
and teams moving to a "purple" stance (defending their own network, and able to
attack each other as well) on the second day.  During the first day, there's a
dedicated red team providing the offensive incentive to the blue teams, as well
as a grey team representing the users/customers of the blue team services.

Each blue team consists of eight players and two pros.  The role of the pros is
increasingly mentorship and less "hands on keyboard", fitting with the Pros v
Joes mission of providing education & mentorship.

## Scoring ##

Scoring was originally based entirely on Health & Welfare checks (i.e., service
up and responding) and flags that can be captured from the hosts.  Originally,
there were "integrity" flags (submitted by blue) and offense flags (submitted by
red).

As of 2017, scoring included health & welfare (service uptime), beacons (red
cell contacting the scoreboard from the server to prove that it is compromised),
flags (in theory anyway), and an in-game marketplace that could have both
positive and negative effects.  2018 scoring details have not yet been released,
but check the 2018 rules when published.

## The Environment ##

The environment changes every year, but it's a highly heterogenous network with
all of the typical services you would find in a corporate network.  At a
minimum, you're likely to see:

- Typical web services (CMS, etc.)
- Mail Server
- Client machines
- Active Directory
- DNS Server

The operating systems will vary, and will include older and newer OSs of both
Windows and Linux varities.  There has also always been a firewall under the
control of each team segregating that team's network from the rest of the
network.  These have been both Cisco ASA firewalls as well as pfSense firewalls.

Each player connects to the game environment using OpenVPN based on
configurations and credentials provided by Dichotomy.

## Preparation ##

There has been an increasing amount of preparation involved in each of the years
I have participated in PvJ.  This preparation has essentially come in two core
forms:

1. Learning about the principles of hardening systems and networks.
2. Preparing scripts, tools, and toolkits for use during the game.

### Fundamentals ###

It turns out that a lot of the fundamental knowledge necessary in securing a
network are just basically system administration fundamentals.  Understanding
how the system works and how systems interact with each other provides much of
the basics of information security.

On both Windows and Linux, it is useful to understand:

- How to install & update software and operating system updates
- How to change permissions of files
- How to start and stop services
- How to set up a host-based firewall
- Basic Shell Commands
- User administration

Understanding basic networking is also useful, including:

- TCP vs UDP
- Stateful vs stateless firewalls
- Using `tcpdump` and Wireshark to debug and understand network traffic

Knowing some kind of scripting language as well can be very useful, especially
if your team prepares some scripts in advance for common operations.  Languages
that I've found useful include:

- Bash
- Powershell
- Python

### Player Toolkit ###

Obviously, if you're playing in a CTF, you'll need a computer.  Many of the
tools you'll want to use are either designed for Linux or are more commonly used
on Linux, so almost everyone will want to have some sort of a Linux environment
available.  I suggest that you use whatever operating system you are most
comfortable with as your "bare metal" operating system, so if that's Windows,
you'll want to run a Linux virtual machine.

As to choice of Linux distribution, if you don't have any personal preference, I
would suggest using [Kali Linux](https://www.kali.org).  It's not that Kali has
anything you can't get on other distributions, but it's well-known in the
security industry, well documented, and based on Debian Linux, which makes it
well-supported and a close cousin of Ubuntu Linux that many have worked with
before.

There are some tools that are absolutely necessary and you should familiarize
yourself with them in advance:

- nmap for network enumeration
- SSH for connecting to Linux Machines
- RDP for connecting to Windows Machines
- git, if your team will use it for managing configurations or scripts
- OpenVPN for connecting to the game environment

Other tools you'll probably want to get some experience with:

- metasploit for going offensive
- Some kind of directory enumeration tool (Dirbuster,
  [WebBorer](https://github.com/Matir/webborer))
- sqlmap for SQL injection

### Useful Resources ###

- [Metasploit
  Unleashed](https://www.offensive-security.com/metasploit-unleashed/) is a free
  online tutorial for penetration testing from Offensive Security.
- [Nmap Network Scanning](https://amzn.to/2tng1EX) is a book all about (and
  from) the Nmap network scanner.  About half the content is [available online
  for free](https://nmap.org/book/toc.html).
- The [Red Team Field Manual](https://amzn.to/2MEud5m) and the [Blue Team Field
  Manual](https://amzn.to/2toabmH) are great references both in preparation, but
  also to have on hand during the game.  They provide quick references for "how
  to" on a variety of applications and operating systems.
- [SANS Hardening Checklists](https://www.sans.org/score/checklists)

## Game Strategy ##

Every team has their own general strategy to the game, but there are a few
things I've found that seem to make gameplay go more smoothly for the team:

- During initial hardening, have one team member working on the firewall.
  Multiple players configuring the firewall is a recipe for lockouts or
  confusion.
- Communicate, communicate, communicate.  Ask questions when needed, and make
  sure it's clear who's working on what.
- Document everything you do.  You don't need to log every command (though it's
  not a bad idea), but you should be able to answer some questions about the
  hosts in your network:
  - What hosts exist?
  - What are the passwords for the accounts?
  - Have the passwords been changed from the defaults?
  - What services are scored?
  - What hardening steps have been applied?

## Dos & Don'ts ##

* **DO** make sure you have a wired ethernet port on your laptop, or a [USB to
  ethernet adapter](https://amzn.to/2MFhpvx) and [an ethernet
  cable](https://amzn.to/2lmA17a).
* **DO** make sure you've set up OpenVPN on your host OS (not in a VM) and
  you've tested it before game day.
* **DO** make sure you've read the rules.  **DON'T** try to cheat, Gold team
  will figure it out and make you pay.
* **DO** make an effort to try new things.  This game is a learning experience.

## Making the Most of It ##

Like so many things in life, the PvJ CTF is a case where you get out of it what
you put into it.  If you think you can learn it all by osmosis or being on the
same team but without making effort, it's unlikely to work out.  PvJ gives you
an enthusiastic team, mentors willing to help, and a top-notch environment to
try things out that you might not have the resources for in your environment.

To all the players: Good luck, learn new things, and have fun!
