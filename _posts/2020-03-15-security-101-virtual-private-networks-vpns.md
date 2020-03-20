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

The most common VPN implementations you're likely to run into are
[IPsec](https://en.wikipedia.org/wiki/IPsec),
[OpenVPN](https://en.wikipedia.org/wiki/OpenVPN), or
[Wireguard](https://en.wikipedia.org/wiki/WireGuard).  I'll cover these in my
examples, as they're the bulk of what individuals might be using for personal
VPNs as well as the most common option for enterprise VPN.  Other relatively
common implementations are Cisco AnyConnect (and the related OpenConnect), L2TP,
OpenSSH's VPN implementation, and other ad-hoc (often TLS-based) protocols.

### A Word on Routing ###

In order to understand how VPNs work, it's useful to understand how routing
works.  Now, this isn't an in-depth dive -- there are [entire
books](https://amzn.to/2Qk2hXM) devoted to the topic -- but it should cover the
basics.  I will only consider the endpoint case with typical routing use cases,
and use IPv4 in all my examples, but the same core elements hold for IPv6.

IP addresses are the sole way the source and destination host for a packet are
identified.  Hostnames are not involved at all, that's the job of DNS.
Additionally, individual sub networks (subnets) are composed of an IP prefix and
the "subnet mask", which specifies how many leading bits of the IP refer to the
network versus the individual host.  For example, `192.168.1.10/24` indicates
that the host is host number 10 in the subnet `192.168.1` (since the first 3
octets are a total of 24 bits long.).

```
% ipcalc 192.168.1.10/24
Address:   192.168.1.10         11000000.10101000.00000001. 00001010
Netmask:   255.255.255.0 = 24   11111111.11111111.11111111. 00000000
Network:   192.168.1.0/24       11000000.10101000.00000001. 00000000
```

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

### VPN Routing ###

Most typically, a VPN will be configured to route all traffic (i.e., the
default) via the VPN server.  This is often done by either a higher priority
routing metric, or a more specific route.  The more specific route may be done
via two routes, one each for the top and bottom half of the IPv4 space.
(`0.0.0.0/1` and `128.0.0.0/1`)

Of course, you need to make sure you can still reach the VPN server -- routing
traffic to the VPN server via the VPN won't work.  (No VPN-ception here!)  So
most VPN software will add a route specifically for your VPN server that goes
via the default route outside the VPN (i.e., your local router).

```
% ip route
default via 192.168.20.1 dev wlp3s0 proto dhcp metric 600
10.13.37.128/26 dev wgnu proto kernel scope link src 10.13.37.148
192.168.0.0/16 via 192.168.20.1 dev wlp3s0 proto dhcp metric 600
192.168.20.0/24 dev wlp3s0 proto kernel scope link src 192.168.20.21 metric 600
```

## Using VPNs for "Privacy" ##

### Commercial VPNs ###

### Rolling Your Own ###

## VPN Misconceptions ##

### VPN "Leaks" ###
