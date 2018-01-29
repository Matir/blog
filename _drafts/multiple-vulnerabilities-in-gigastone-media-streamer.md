---
layout: post
title: "Playing with the Gigastone Media Streamer Plus"
category: Security
tags:
  - Security
  - Advisories
  - Research
excerpt:
    A few months ago, I was shopping on woot.com and
    discovered the Gigastone Media Streamer Plus for about
    $25.  I figured this might be something occassionally useful, or at least fun to
    look at for security vulnerabilities.  When it arrived, I didn't get around to
    it for quite a while, and then when I finally did, I was terribly disappointed
    in it as a security research target -- it was just too easy.
---

* TOC
{:toc}

## Background ##

A few months ago, I was shopping on [woot.com](https://www.woot.com) and
discovered the [Gigastone Media Streamer Plus](http://amzn.to/2C76sRQ) for about
$25.  I figured this might be something occassionally useful, or at least fun to
look at for security vulnerabilities.  When it arrived, I didn't get around to
it for quite a while, and then when I finally did, I was terribly disappointed
in it as a security research target -- it was just too easy.

The Gigastone Media Streamer Plus is designed to provide streaming from an
attached USB drive or SD card over a wireless network.  It features a built-in
battery that can be used to charge a device as well.  In concept, it sounds
pretty awesome (and there's many such devices on the market) but it turns out
there's no security to speak of in this particular device.

## Exploration ##

By default the device creates its own wireless network that you can connect to
in order to configure and stream, but it can quickly be reconfigured as a client
on another wireless network.  I chose the latter and joined it to my lab network
so I wouldn't need to be connected to *just* the device during my research.

### NMAP Scan ###

The first thing I do when something touches the network is perform an NMAP scan.
I like to use the version scan as well, though it's not nearly as accurate on
embedded devices as it is on more common client/server setups.  NMAP quickly
returned some interesting findings:

```
# Nmap 7.40 scan initiated as: nmap -sV -T4 -p1-1024 -Pn -o gigastone.nmap 192.168.40.114
Nmap scan report for 192.168.40.114
Host is up (0.14s latency).
Not shown: 1020 closed ports
PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 2.0.8 or later
23/tcp open  telnet  security DVR telnetd (many brands)
53/tcp open  domain  dnsmasq 2.52
80/tcp open  http    Boa httpd
MAC Address: C0:34:B4:80:29:EB (Gigastone)
Service Info: Host: use

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done -- 1 IP address (1 host up) scanned in 22.33 seconds
```

Hrrm, FTP and Telnet.  I'm sure they're for a good reason.

### Web Interface  ###

The web interface is functional, but not attractive.  It provides functionality
for uploading and downloading files as well as changing settings, such as
wireless configuration, WAN/LAN settings, and storage usage.

I noticed that, when loading the Settings page, you would sometimes get the
settings visible *before* authenticating to the admin interface.

### Problems with Burp Suite ###

While playing with this device, I did notice a bug in Burp Suite.  The Gigastone
Media Streamer Plus does not adhere to the HTTP RFCs, and all of their cgi-bin
scripts send only `\r` at the end of line, instead of `\r\n` per the RFC.
Browsers are forgiving, so they handled this gracefully.  Unfortunately, when
passing the traffic through Burp Suite, it transformed the '\r\r' at the end of
the response headers to `\n\r\n\r\n`.  This causes the browser to interpret an
extra blank line at the beginning of the response.  Still *not* a problem for
the browser parsing things, but slightly more a problem for the Gigastone
Javascript parsing its own custom response format (newline-separated).

I reported the [bug to PortSwigger](https://support.portswigger.net/customer/portal/questions/17177658-header-lines-with-improper-terminators-manipulated-by-burp-in-strange-ways)
and not only got a prompt confirmation of the bug, but a Python Burp extension
to work around the issue until a proper fix lands in Burp Suite.  That's an
incredible level of support from the authors of a quality tool.

## Vulnerabilities ##

### Telnet with Default Credentials ###

The device exposes telnet to the local network and accepts username 'root' and
password 'root'.  This gives full control of the device to anyone on the local
network.

### Information Disclosure: Administrative PIN (and Other Settings) ###

The administrative PIN can be retrieved by an unauthenticated request to an API.
In fact, the default admin interface uses this API to compare the entered PIN
entirely on the client side.

```
% curl 'http://192.168.40.114/cgi-bin/gadmin'
get
1234
```

In fact, all of the administrative settings can be retrieved by unauthenticated
requests, such as the WiFi settings.  (Though, on a shared network, this is of
limited value.)

```
% curl 'http://192.168.40.114/cgi-bin/cgiNK'
AP_SSID=LabNet
AP_SECMODE=WPA2
PSK_KEY=ThisIsNotAGoodPassphrase
AP_PRIMARY_KEY=1
WEPKEY_1=
WEPKEY_2=
WEPKEY_3=
WEPKEY_4=
```

### Authentication Bypass: Everything ###

None of the administrative APIs actually require any authentication.  The admin
PIN is never sent with requests, no session cookie is set, and there are no
other authentication controls.  For example, the admin PIN can be set via a GET
request as follows:

```
% curl 'http://192.168.40.114/cgi-bin/gadmin?set=4444'
set
0
4444
```

## Timeline ##

- Discovered in ~May 2017
- Reported Jan 28 2018
