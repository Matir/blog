---
layout: post
title: "The Machine Inside the Machine"
date: 2014-05-13 04:24:00 +0000
permalink: /2014/05/13/the-machine-inside-the-machine/
category: Security
tags:
  - Security
  - System Administration
---
Imagine this scenario:
> One of your employees visits a site offering a program to download videos from a popular video site.  Because they'd like to throw some videos on their phone, they download and install it, but it comes with a hitchhiker: a RAT, or remote access trojan.  So Trudy, an attacker, has a foothold, but the user isn't an administrator, so she starts looking at the network for a place to pivot.  Scanning a private subnet, she finds a number of consecutive IP addresses all offering webservers, FTP servers, and even telnet!  Connecting to one, the attacker suddenly realizes she has just found her golden ticket...

Dell calls it iDRAC; IBM refers to it as RSA or IMM; HP likes iLO; and Intel goes with AMT.  Whatever the name, most servers offer an out-of-band management option, and those are an oft-overlooked potential backdoor into your network.  Generally these devices use their own network connection, are powered even if the server is shut down (so long as the power supplies are on), and offer a number of powerful features:

- Remote console (most often a Java applet)
- Attach remote drives (ISOs or disk images)
- Reboot server
- Update firmware
- Control boot and BIOS/EFI settings

What can our attacker do with this?  These devices are intended to provide system administrators with access roughly equivalent to physical access, and for attackers, they do the same.

> Connecting to the out-of-band controller, Trudy hopes that whoever racked the server hooked up the controller but did no more configuration, such as changing the passwords.  Almost all use a static password, so upon seeing the logo on the login screen, she immediately knew to try PASSW0RD, and was presented with the admin interface moments later.  Launching the Java-based remote console, she was delighted to see a Windows Server 2012 interface with the hostname "DC2", indicating the server was probably a Domain Controller, but was slightly disappointed to see that someone hadn't done her the favor of leaving it logged in.

>No matter, she had her bag full of tricks.  She mounted an ISO of Kali Linux and, hoping the failover would work properly, clicked the reboot icon.  After the system booted, she mounted the hard drives and replaced a few less-critical service executables with binaries that had some extra functionality.  As she disconnected her ISO and power-cycled the server again, she fired up Metasploit on her laptop and started listening for connections.  Shortly after the server booted, she saw an incoming connection pop up on her screen.

>     [*] Sending stage (748032 bytes) to 192.168.9.9
>     [*] Meterpreter session 1 opened (10.3.13.37:4444 -> 192.168.9.9:1051)
>     [*] Starting interaction with 1...
>     meterpreter > getuid
>     Server username: NT AUTHORITY\SYSTEM

Due to an insecure Lights-Out Management device, Trudy now has SYSTEM on a domain controller at her target.  Even with servers configured to best practices and fully patched, the network is now wide open.  Trudy is free to pivot throughout the network, extract sensitive data, and whatever else she'd like.  In short, you've been pwn3d.

####Securing Out of Band Management

Not all hope is lost, however.  While these devices pose a risk, they are also very useful.  We can secure the controllers, but it takes planning.

1. If you're not going to use them, don't connect them.  If it's not on the network, it's not the way in.
2. Maintain inventory of these devices, and include them in your patch management lifecycle.  Patch them now.
3. Like any server, disable unneeded services.  Are you really going to use the telnet service on it?  Ideally, only leave encrypted services around so passive sniffers aren't a risk.
4. Change the passwords.  Nearly all of these devices have a default password that is the same across the board, so it doesn't take much to get in if you haven't changed the passwords.

Watch out for the machine within the machine!
