---
layout: post
title: "Weekly Reading List for 1/25/14"
date: 2014-01-25 08:00:00 +0000
permalink: /2014/01/25/weekly-reading-list-for-12514/
category: Security
tags:
  - CTF
  - Security
redirect_from:
  - /blog/weekly-reading-list-for-12514/
---
This week, we're focusing on binary exploitation and reversing.  (Thanks to Ghost in the Shellcode for making me feel stupid with all their binary pwning challenges!)

#### Basic Shellcode Examples
Gal Badishi has a great set of [Basic Shellcode Examples](https://badishi.com/basic-shellcode-example/).  It's almost two years old, but a good primer into how basic shellcode works.  x86 hasn't changed (yes, I'm ignoring x64 for now), so still quite a relevant resource for those of us who have leaned on msfvenom/msfpayload for our payload needs.

#### Project Shellcode
Going beyond the basic, [Project Shellcode](http://projectshellcode.com/) is a site full of resources for crafting and understanding shellcode.  Based on training classes used at BlackHat 2012, they walk through all the steps in writing shellcode.

#### x86 Assembly Guide
If the shellcode above looked like Greek, perhaps it's time for an x86 assembly primer/refresher.  UVA's CS department has you covered with their [x86 Assembly Guide](http://www.cs.virginia.edu/~evans/cs216/guides/x86.html), used in their CS216 class.  It also has some useful reference to how the instructions work.

#### GNU Debugger Tutorial
If you want to observe the behavior of a running program, you're going to want a debugger.  If you're running on Linux and haven't spent the $1200 for IDA pro, you're probably using the GNU Debugger, better known as GDB.  RMS (no, not *that* [RMS](http://stallman.org/)) has a great [gdb tutorial](http://www.unknownroad.com/rtfm/gdbtut/).
