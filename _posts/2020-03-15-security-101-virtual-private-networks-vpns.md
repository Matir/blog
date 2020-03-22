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

<!--more-->

## VPN Basics ##

At the most basic level, a VPN is intended to provide a service that is
equivalent to having a private network connection, such as a leased fiber,
between two endpoints.  The goal is to provide confidentiality and integrity for
the traffic travelling between those endpoints, which is usually accomplished by
cryptography (encryption).

<img src="/img/vpn/vpn-overview.svg">

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

For example, when connected via Wireguard, I have the following routing tables:

```
% ip route
default dev wg0 table 51820 scope link
default via 192.168.20.1 dev wlp3s0 proto dhcp metric 600
10.13.37.128/26 dev wg0 proto kernel scope link src 10.13.37.148
192.168.20.0/24 dev wlp3s0 proto kernel scope link src 192.168.20.21 metric 600
```

`10.13.37.148/26` is the address and subnet for my VPN, and `192.168.20.21/24`
is my local IP address on my local network.  The routing table provides for a
default via `wg0`, my wireguard interface.  There's a routing rule that prevents
wireguard traffic from itself going over that route, so it falls to the next
route, which uses my home router (running [pfSense](https://www.pfsense.org/))
to get to the VPN server.

The VPN only provides its confidentiality and integrity for packets that travel
via its route (and so go within the tunnel).  The routing table is responsible
for selecting whether a packet will go via the VPN tunnel or via the normal
(e.g., non-encrypted) network interface.

Just for fun, I dropped my Wireguard VPN connection and switched to an OpenVPN
connection to the same server.  Here's what the routing table looks like then
(tun0 is the VPN interface):

```
% ip route
default via 10.13.37.1 dev tun0 proto static metric 50
default via 192.168.20.1 dev wlp3s0 proto dhcp metric 600
10.13.37.0/26 dev tun0 proto kernel scope link src 10.13.37.2 metric 50
10.13.37.0/24 via 10.13.37.1 dev tun0 proto static metric 50
198.51.100.6 via 192.168.20.1 dev wlp3s0 proto static metric 600
192.168.20.0/24 dev wlp3s0 proto kernel scope link src 192.168.20.21 metric 600
192.168.20.1 dev wlp3s0 proto static scope link metric 600
```

This is a little bit more complicated, but you'll still note the two default
routes.  In this case, instead of using a routing rule, OpenVPN sets the
`metric` of the VPN route to a lower value.  You can think of a `metric` as
being a cost to a route: if multiple routes are equally specific, then the
lowest `metric` (cost) is the one selected by the kernel for routing the packet.

Otherwise, the routing table is very similar, but you'll also notice the route
specifically for the VPN server (`198.51.100.6`) is routed via my local gateway
(`192.168.20.1`).  This is how OpenVPN ensures that its packets (those encrypted
and signed by the VPN client) are not routed over the VPN itself by the kernel.

## Using VPNs for "Privacy" vs "Security" ##

There are many reasons for using a VPN, but for many people, they boil down to
being described as "Privacy" or "Security".  The single most important thing to
remember is that the VPN offers **no protection** to data in transit **between
the VPN server and the remote server**.  Where data reaches the remote server,
it looks exactly the same as if it had been sent directly.

Some VPNs are just used to access private resources on the remote network (e.g.,
corporate VPNs), but a lot of VPN usage these days is routing all traffic,
including internet traffic, over the VPN connection.  I'll mostly consider those
scenarios below.

When talking about what a VPN gets you, you also need to consider your "threat
model".  Specifically, who is your adversary and what do you want to prevent
them from being able to do?  Some common examples of concerns people have and
where a VPN can actually benefit you include:

* (Privacy) Prevent their ISP from being able to market their browsing data
* (Security) Prevent man-in-the-middle attacks on public/shared WiFi
* (Privacy) Prevent tracking by "changing" your IP address

Some scenarios that people want to achieve, but a VPN is ineffective for,
include:

* (Privacy) Preventing "anyone" from being able to see what sites you're
  visiting
* (Privacy) Prevent network-wide adversaries (e.g., governments) from tracking
  your browsing activity
* (Privacy) Prevent all tracking of your browsing

### Commercial VPNs ###

Commercial VPN providers have the advantage of mixing all of your traffic with
that of their other customers.  Typically, a couple of dozen or more inbound
connections come out from the same IP address.  They also come with no
administration overhead, and often have servers in a variety of locations, which
can be useful if you'd like to access Geo-Restricted content.  (Please comply
with the appropriate ToS however.)

On the flip side, using a commercial VPN server has just moved the endpoint of
your plaintext traffic to another point, so if privacy is your main concern,
you'd better trust your VPN provider more than you trust your ISP.

### Rolling Your Own ###

Rolling your own gives you the ultimate in control of your VPN server, but does
require some technical know-how.  I really like the approach of using
[Trail of Bits' Algo](https://github.com/trailofbits/algo) on
[DigitalOcean](https://m.do.co/c/b2cffefc9c81) for a fast custom VPN server.
When rolling your own, you're not competing with others for bandwidth and can
choose a hosting provider in the location you want to get nearly any egress you
want.

## VPN Misconceptions ##

### VPN "Leaks" ###
