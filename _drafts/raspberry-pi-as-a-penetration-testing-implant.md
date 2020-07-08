---
layout: post
title: "Raspberry Pi as a Penetration Testing Implant (Dropbox)"
category: Security
tags:
  - Penetration Testing
  - Red Team
---

Sometimes, especially in the time of COVID-19, you can't go onsite for a
penetration test.  Or maybe you can only get in briefly on a physical test, and
want to leave behind a dropbox that you can remotely connect to.  Of course, it
could also be part of the desired test itself if incident response testing is
in-scope -- can they find your malicious device?

In all of these cases, one great option is a small single-board computer, the
best known of which is the Raspberry Pi.  It's inexpensive, compact, easy to
come by, and very flexible.  It may not be perfect in every case, but it gets
the job done in a lot of cases.

I'll use this opportunity to discuss the setups I've done in the past and the
things I would change when doing it again or alternatives I considered.  I hope
some will find this useful.  Some familiarity with the Linux command line is
assumed.

<!--more-->

## Table of Contents
{:.no_toc}

* TOC
{:toc}

## General Principles of Dropboxes

As mentioned above, a dropbox is a device that you can connect to the target
network and leave behind.  (In an authorized test, you'd likely get your
hardware back at the end, but it's always possible that someone
steals/destroys/etc. your device.)  This serves as your foothold into the target
network.

For some penetration tests, you'll be able to provide your contact the dropbox
and have them connect it to the network.  This can allow you to have an
internally scoped test but not require your physical presence at their site.
This can be useful to avoid travel costs (or, currently, avoid COVID-19).  In
this case, you'll have an agreed-upon network segment that it will be connected
to.  (Commonly, this will be a network segment with workstations as opposed to a
privileged segment.)

If you're going physical and want to leave a dropbox behind, you'll have to be
more opportunistic about things.  You'll get whatever network segment you get,
so you might want to consider dropping a couple of devices if the opportunity
presents itself.

In all these cases, you'll need to remotely control the dropbox over some
network connection, and then operate it to perform your attacks.

## Connecting Back

### In Band

### Out of Band

## Setup & Challenges

### Resiliency

### Software

### Confidentiality/Data Protection

### Network Access Control

## Other Options

### Dedicated Devices

### Alternative Single-Board Computers
