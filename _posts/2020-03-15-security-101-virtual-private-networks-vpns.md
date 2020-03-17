---
layout: post
title: "Security 101: Virtual Private Networks (VPNs)"
category: Security
date: 2020-03-15
tags:
  - Security 101
---

I'm trying something new -- a "Security 101" series.  I hope to make these
topics readable for those with no security background.  I'm going to pick topics
that are either related to my other posts (such as foundational knowledge) or
just things that I think are relevant or misunderstood.

Today, I want to cover Virtual Private Networks, commonly known as VPNs.  First
I want to talk about what they are and how they work, then about commercial VPN
providers, and finally about common misconceptions.

## VPN Basics ##

At the most basic level, a VPN is intended to provide a service that is
equivalent to having a private network connection, such as a leased fiber,
between two endpoints.  The goal is to provide confidentiality and integrity for
the traffic travelling between those endpoints, which is usually accomplished by
cryptography (encryption).

<!-- todo: general VPN image -->

The traffic tunneled by VPNs can operate at either Layer 2
(sometimes referred to as "bridging") or
Layer 3 (sometimes referred to as "routing") of the [OSI
model](https://en.wikipedia.org/wiki/OSI_model).  Layer 2 VPNs provide a more
seamless experience between the two endpoints (e.g., device autodiscovery, etc.)
but are less common and not supported on all platforms.  Most VPN protocols
operate at the application layer, but IPsec is an extension to IPv4, so operates
at Layer 3.

The most common VPN implementations you're likely to run into are IPsec,
OpenVPN, or Wireguard.  I'll cover these in my examples, as they're the bulk of
what individuals might be using for personal VPNs as well as the most common
option for enterprise VPN.  Other relatively common implementations are Cisco
AnyConnect (and the related OpenConnect), L2TP, OpenSSH's VPN implementation,
and other ad-hoc (often TLS-based) protocols.

### A Word on Routing ###

In order to understand how VPNs work, it's useful to understand how routing
works.  Now, this isn't an in-depth dive -- there are [entire
books](https://amzn.to/2Qk2hXM) devoted to the topic -- but it should cover the
basics.  I will only consider the endpoint case with typical routing use cases,
and use IPv4 in all my examples, but the same core elements hold for IPv6.

IP addresses are the single way the source and destination host for a packet are
identified.  Hostnames are not involved at all, that's the job of DNS.
Additionally, individual sub networks (subnets) are composed of an IP prefix and
the "subnet mask", which specifies how many leading bits of the IP refer to the
network versus the individual host.  For example, `192.168.1.10/24` indicates
that the host is host number 10 in the subnet `192.168.1` (since the first 3
numbers are 24 bits long.).

<!-- todo: subnet bitmask diagram -->

When your computer wants to send a packet to another computer, it has to figure
out how to do so.  If the two machines are on the same sub network, this is
easy -- it can be sent directly on the appropriate interface.  So if the host
with the IP `192.168.1.10/24` on it's wireless network interface wants to send a
packet to `192.168.1.22`, it will just send it directly on that interface.

If, however, it wants to send a packet to `1.1.1.1`, it will need to send it via
a router (a device that routes packets from one network to another).  Most
often, this will be via the "default route", sometimes represented as
`0.0.0.0/0`.  This is the route used when the packet doesn't match any other
route.  In between the extremes of the same network and the default route can be
any number of other routes.  When routing an outbound packet, the kernel picks
the most specific route.
