---
layout: post
title: "Useful ARM References"
category: Security
date: 2017-03-21
tags:
  - ARM
  - pwning
  - Wargames
---

I started playing the excellent [IOARM wargame on netgarage](http://ioarm.netgarage.org/).
No, don't be expecting spoilers, hints, or walk-throughs, I'm not that kind of
guy.  This is merely a list of interesting reading I've discovered to help me
understand the ARM architecture and ARM assembly.

* [Docker containers for cross-compilation](https://github.com/dockcross/dockcross)
* [ARMwiki](https://www.heyrick.co.uk/armwiki/Main_Page)
* [ARM Syscalls](https://w3challs.com/syscalls/?arch=arm_strong) (I'm not sure
  why they all seem to have +0x900000 to their value, you certainly don't use
  them that way.)
* [ARM Assembly System Calls](http://thinkingeek.com/2014/05/24/arm-assembler-raspberry-pi-chapter-19/)
  (This is part of a bigger series that looks excellent at a glance.)
* [Shellcode on ARM architecture](http://shell-storm.org/blog/Shellcode-On-ARM-Architecture/)
* [Syscall.tbl for ARM](https://github.com/torvalds/linux/blob/57fd0b77d659d5733434d3ce37cf606273abb1e8/arch/arm/tools/syscall.tbl)
  (Use with the w3challs.com version to see arguments used.)
* [Calling Conventions](http://wiki.osdev.org/Calling_Conventions)
* [GDB with User-Mode QEMU](https://yurovsky.github.io/2016/12/14/qemu-user-mode/)
