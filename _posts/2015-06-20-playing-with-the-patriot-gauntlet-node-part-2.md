---
layout: post
title: "Playing with the Patriot Gauntlet Node (Part 2)"
date: 2015-06-20 22:13:50 +0000
permalink: /blog/playing-with-the-patriot-gauntlet-node-part-2/
category: Security
tags: Security,Patriot Gauntlet Node,Embedded Systems
---
Despite the fact that it's been over 2 years since I posted [Part 1](/blog/2013/02/05/playing-with-the-patriot-gauntlet-node-part-1/), I got bored and decided I should take another look at the [Patriot Gauntlet Node](http://www.amazon.com/gp/product/B008KW61XK/ref=as_li_tl?ie=UTF8&camp=1789&creative=390957&creativeASIN=B008KW61XK&linkCode=as2&tag=systemovecom-20&linkId=YX2FFFV7XA7LVSVW).  So I go and grab the latest firmware from Patriot's website (V21_1.2.4.6) and use the same binwalk techniques described in the first post, I extracted the latest firmware.

So, the TL;DR is: It's unexciting because Patriot makes no effort to secure the device.  It seems that their security model is "if you're on the network, you own the device", which is pretty much the case.  Not only can you enable telnet as I've discussed before, there's even a convenient web-based interface to run commands: http://10.10.10.254:8088/adm/system_command.asp.  Oh, and it's not authenticated.  Even if you set an admin password (which is hidden at http://10.10.10.254:8088/adm/management.asp).

The device runs two webservers: on port 80 you have httpd from busybox, and on port 8088, you have a [proprietary embedded webserver called GoAhead](https://embedthis.com/goahead/).  It uses not ASP, as the file extensions would have you believe, but actually uses an embedded JavaScript interpreter called Ejscript to generate active pages.

I don't intend to spend much more time on this device from a security PoV: it doesn't seem intended to be secure at all, so it's not like there's anything to break.  The device is essentially pre-rooted, so go to town and have fun!
