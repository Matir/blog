---
layout: post
title: "So, is Windows 10 Spying On You?"
date: 2015-08-16 21:00:02 +0000
permalink: /blog/so-is-windows-10-spying-on-you/
category: Security
tags: Security,Windows
---
"Extraordinary claims require extraordinary evidence."

A few days ago, [localghost.org posted a translation](http://localghost.org/posts/a-traffic-analysis-of-windows-10) of [a Czech article](http://aeronet.cz/news/analyza-windows-10-ve-svem-principu-jde-o-pouhy-terminal-na-sber-informaci-o-uzivateli-jeho-prstech-ocich-a-hlasu/) alledging Windows 10 "phones home" in a number of ways.  I was a little surprised, and more than a little alarmed, by some of the claims.  Rather than blindly repost the claims, I decided it would be a good idea to see what I could test for myself.  Rob Seder [has done similarly](http://blog.robseder.com/2015/08/16/whats-the-real-deal-with-windows-10-and-privacy/) but I'm taking it a step further to look at the real traffic contents.

### Tools & Setup ###

I'm running the Windows 10 Insider Preview (which, admittedly, may not be the
same as the release, but it's what I had access to) in VirtualBox.  The NIC on
my Windows 10 VM is connected to an internal network to a Debian VM with my
tools installed, which is in turn connected out to the internet.  On the Debian
VM, I'm using mitmproxy to perform a traffic MITM.  I've also used VirtualBox's
[network tracing](https://www.virtualbox.org/wiki/Network_tips) to collect
additional data.

Currently, I have all privacy settings set to the default, but I am not signed
into a Microsoft Live account.  This is an attempt to replicate the findings
from the original article.  At the moment, I'm only looking at HTTP/HTTPS
traffic in detail, even though the original article wasn't even specific enough
to indicate what protocols were being used.

### Claim 1. All text typed on the keyboard is sent to Microsoft ###

When typing into the search bar within the Start menu, an HTTPS request is sent
after each character entered.  Presumably this is to give web results along with
local results, but the amount of additional metadata included is just
mind-boggling.  Here's what the request for such a search looks like (some
headers modified):

    GET /AS/API/WindowsCortanaPane/V2/Suggestions?qry=about&cp=5&cvid=ce8c2c3ad6704645bb207c0401d709aa&ig=7fdd08f6d6474ead86e3c71404e36dd6&cc=US&setlang=en-US HTTP/1.1
    Accept:                        */*
    X-BM-ClientFeatures:           FontV4, OemEnabled
    X-Search-SafeSearch:           Moderate
    X-Device-MachineId:            {73737373-9999-4444-9999-A8A8A8A8A8A8}
    X-BM-Market:                   US
    X-BM-DateFormat:               M/d/yyyy
    X-Device-OSSKU:                48
    X-Device-NetworkType:          ethernet
    X-BM-DTZ:                      -420
    X-BM-UserDisplayName:          Tester
    X-DeviceID:                    0100D33317836214
    X-BM-DeviceScale:              100
    X-Device-Manufacturer:         innotek GmbH
    X-BM-Theme:                    ffffff;005a9e
    X-BM-DeviceDimensionsLogical:  320x622
    X-BM-DeviceDimensions:         320x622
    X-Device-Product:              VirtualBox
    X-BM-CBT:                      1439740000
    X-Device-isOptin:              false
    X-Device-Touch:                false
    X-AIS-AuthToken:               AISToken ApplicationId=25555555-ffff-4444-cccc-a7a7a7a7a7a7&ExpiresOn=1440301800&HMACSHA256=CS
                                   y7XaNyyCE8oAZPeN%2b6IJ4ZrpqDDRZUIJyKvrIKnTA%3d
    X-Device-ClientSession:        95290000000000000000000000000000
    X-Search-AppId:                Microsoft.Windows.Cortana_cw5n1h2txyewy!CortanaUI
    X-MSEdge-ExternalExpType:      JointCoord
    X-MSEdge-ExternalExp:          sup001,pleasenosrm40ct,d-thshld42,d-thshld77,d-thshld78
    Referer:                       https://www.bing.com/
    Accept-Language:               en-US
    Accept-Encoding:               gzip, deflate
    User-Agent:                    Mozilla/5.0 (Windows NT 10.0; Win64; x64; Trident/7.0; rv:11.0; Cortana 1.4.8.152;
                                   10.0.0.0.10240.21) like Gecko
    Host:                          www.bing.com
    Connection:                    Keep-Alive
    Cookie:                        SA_SUPERFRESH_SUPPRESS=SUPPRESS=0&LAST=1439745358300; SRCHD=AF=NOFORM; ...

In addition to my query, "about", it sends a "DeviceID", a "MachineId", the username I'm logged in as, the
platform (VirtualBox), and a number of opaque identifiers in the query, the X-AIS-AuthToken, and the Cookies.
That's a lot of information just to give you search results.

### Claim 2. Telemetry including file metadata is sent to Microsoft ###

I searched for several movie titles, including "Mission Impossible", "Hackers",
and "Inside Out."  Other than the Cortana suggestions above, I didn't see any
traffic pertaining to these searches.  Certainly, I didn't see any evidence of
uploading a list of multimedia files from my Windows 10 system, as described in
the original post.

I also searched for a phone number in the edge browser, as described in the
original post.  (Specifically, I search for 867-5309.)  The only related traffic
I saw is traffic to the site on which I performed the search (yellowpages.com).
No traffic containing that phone number went to any Microsoft-run server, as far
as I can tell.

### Claim 3. When a webcam is connected, 35MB of data gets sent ###

Nope.  Not even close.  I shut down the VM, started a new PCAP, restarted, and attached a
webcam via USB forwarding in VirtualBox.  After the drivers were fully
installed, I shut down the system.  The total size of the pcap was under 800k in
size, a far cry from the claimed 35MB.  Looking at mitmproxy and the pcap, the
largest single connection was ~82kB in size.  I have no idea what traffic he
saw, but I saw no alarming connection related to plugging in a webcam.  My best
guess is maybe it's actually 35MB of download, and his webcam required a driver
download.  (Admittedly a large driver, but I've seen bigger.)

![Traffic from Connecting a Webcam][1]

### Claim 4. Everything said into a microphone is sent ###

Even when attempting to use the speech recognition in Windows, I saw nothing
that was large enough to be audio spoken being transferred.  Additionally, no
intercepted HTTP or HTTPS traffic contained the raw words that I spoke to the
voice recognition service.  Maybe if signed in to Windows Live, Cortana performs
uploads, but without being signed in, I saw nothing representative of the words
I used with speech recognition.

### Claim 5. Large volumes of data are uploaded when Windows is left unattended ###

I left Windows running for >1 hour while I went and had lunch.  There were a
small number of HTTP(s) requests, but they all seemed to be related to either
updating the weather information displayed in the tiles or checking for new
Windows updates.  I don't know what the OP considers "large volumes", but I'm
not seeing it.

### Conclusion ###

The original post made some extraordinary claims, and I'm not seeing anything to
the degree they claimed.  To be sure, Windows 10 shares more data with Microsoft
than I'd be comfortable with, particularly if Cortana is enabled, but it doesn't
seem to be anything like the levels described in the article.  I wish the
original poster had posted more about the type of traffic he was seeing, the
specific requests, or even his methodology for testing.

The only dubious behavior I observed was sending every keystroke in the Windows
Start Menu to the servers, but I understand that combined Computer/Web search is
being sold as a feature, and this is necessary for that feature.  I don't know
why all the metadata is needed, and it's possibly excessive, but this isn't the
keylogger the original post claimed.

Unfortunately, it's impossible to disprove his claims, but if it's as bad as
suggested, reproducing it should've been possible, and I've been unable to
reproduce it.  I encourage others to try it as well -- if enough of us do it, it
should be possible to either confirm or strongly refute the original claims.


  [1]: /img/blog/windows10traffic.png
