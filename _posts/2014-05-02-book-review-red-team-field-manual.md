---
layout: post
title: "Book Review: Red Team Field Manual"
date: 2014-05-02 15:24:27 +0000
permalink: /blog/book-review-red-team-field-manual/
categories: Computer,Security
tags: Red Team,Security,Pentesting
---
I recently picked up a copy of the [Red Team Field Manual](http://www.amazon.com/gp/product/1494295504/ref=as_li_tl?ie=UTF8&camp=1789&creative=390957&creativeASIN=1494295504&linkCode=as2&tag=systemovecom-20&linkId=VUHBPTAFLWN7MNBT) on Amazon after hearing good things from a few people in the industry.  It's information dense, basically a concatenation of cheat sheets for everything you'd want to do during a pentest.  I'm mostly a Linux/Unix guy, and given my role on an internal red team for a mostly Linux company, I don't do a lot of Windows.  However, I recently had an engagement where we were targeting Windows, and I wish I'd had the RTFM handy then: there are a number of great pointers for Windows that I could've leveraged to make my engagement go more smoothly.  Additionally, the book provides coverage for other platforms, like Cisco IOS, and for various scripting situations in Powershell, Python, or even [Scapy](http://www.secdev.org/projects/scapy/).

Here's the complete list of coverage from the table of contents:

- *NIX
- Windows
- Networking
- Tips and Tricks
- Tool Syntax
- Web
- Databases
- Programming
- Wireless
- References

There are also various tables of pure information scattered throughout the book, ranging from an ASCII chart to regex syntax to a subnetting guide.

Unfortunately, the book is not without its shortcomings: many of the command lines provide no explanation for the "fill in the blank" options, leaving that to the memory of the reader, and others refer to config files (such as for wpa_supplicant) without providing any information on the contents or syntax of the files.  Additionally, there are 3 characters that are consistently unreadable throughout my copy of RTFM: *, &lt;, and &gt;.  I'm not sure if these were in a different color before the printing, leading to them being **extremely** light in the text or what could've caused this, but I have to read carefully for them.  Ben Clark uses &lt;foo&gt; to delimit the fill-in-the-blank options, and obviously they're used for shell redirection as well, which both makes them critical characters to be hard to see as well as leads to potential confusion from less-experienced readers.  The formatting is also inconsistent, with some commands prefixed with something similar to a shell prompt (often '&gt; ') and others lay bare, and line wrapping leads you scratching your head at a few, though an experienced pentester should be able to overcome both of these with little trouble.

Overall, this is definitely a handy quick reference for any pentester (or for that matter, anyone who has to do administration or networking where they might find themselves without an internet connection) and for $9, it's totally worth having a copy in your kit.
