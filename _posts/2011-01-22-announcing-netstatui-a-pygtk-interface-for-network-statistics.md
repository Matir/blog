---
layout: post
title: "Announcing NetStatUI: A PyGTK interface for network statistics"
date: 2011-01-22 18:06:48 +0000
permalink: /2011/01/22/announcing-netstatui-a-pygtk-interface-for-network-statistics/
category: Linux
tags: Linux,Ubuntu,Open Source,NetStatUI
---
NetStatUI is my first significant FOSS release.  It's also my first significant Python project and my first use of GTK+.  Yes, that's a lot of firsts all at once, so I apologize if I've done things sub-optimally.  I'm still learning some of the wonderful niceties of Python (a subject of a later post) and so I may have done some things "the other way." NetStatUI is a program to display statistics and information about the IP connections currently on your system. It is an attempt to provide a usable NetStat work-alike for the desktop user.  Many new users are shy of the command line, and having a graphical version may be useful.


Homepage: https://launchpad.net/netstatui

NetStatUI has several caveats, and many more TODOs, described below. This is my first significant Python application, my first GTK+ application, and probably my first significant FOSS application. Feedback is welcomed and appreciated.

CAVEATS:

Displaying hostnames is INCREDIBLY slow.  For some reason, Python's implementation of socket.gethostbyaddr() is very slow.  We do cache lookups to speed up future calls, but the first time a full screen is looked up, it can take 30s+
NetStatUI does not support Unix domain sockets.  At present, there are no plans to change this.  If you need Unix domain sockets, you likely know how to use netstat(8).  If you need Unix domain sockets and DON'T know how to use netstat(8), I'd love to hear what your use case is.
For some things, NetStatUI requires root access.  I hate running things on my desktop as root when I can avoid it, but NetStatUI gathers process information by walking the /proc tree, and only root can read other user's process information.  See the -p option to netstat(8) for more details.
TODO:

NetStatUI is intended to have columns to display per-connection bandwidth usage.  My intent is to gather this information via the conntrack interface.  Parsing ip_conntrack is non-trivial, but there is a Python binding for libconntrack.  I'll need to test it out and see if it meets the needs of NetStatUI.
The Kill Process and TCPDump buttons are clickable, but don't do anything.  Those are likely to be implemented in short order.
While the GPL does not require this, I'd appreciate that if you create
a derivative work, you let me know so I can see what you've done.  My
contact information is at the top of this document.  Thanks for giving
NetStatUI a try!

To obtain NetStatUI right now, you'll need to use the bzr distributed version control tool.  As NetStatUI is hosted on launchpad, it's as simple as bzr branch lp:netstatui.
