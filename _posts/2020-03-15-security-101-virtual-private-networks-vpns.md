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

Note that users of Docker or virtual machines are likely to see a number of
additional routes going over the virtual interfaces to containers/VMs.

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

If you're after anonymity online, it's important to consider who you're seeking
anonymity from.  If you're only concerned about advertisers, website operators,
etc., than a commercial VPN helps provide a pseudonymous browsing profile
compared to coming directly from your ISP-provided connection.

### Rolling Your Own ###

Rolling your own gives you the ultimate in control of your VPN server, but does
require some technical know-how.  I really like the approach of using
[Trail of Bits' Algo](https://github.com/trailofbits/algo) on
[DigitalOcean](https://m.do.co/c/b2cffefc9c81) for a fast custom VPN server.
When rolling your own, you're not competing with others for bandwidth and can
choose a hosting provider in the location you want to get nearly any egress you
want.

Alternatively, you can set up either OpenVPN or Wireguard yourself.  While
Wireguard is considered cleaner and uses more modern cryptography, OpenVPN takes
care of a few things (like IP address assignment) that Wireguard does not.  Both
are well-documented at this point and have clients available for a variety of
platforms.

Note that a private VPN generally does not have the advantage of mixing your
traffic with that of others -- you're essentially moving your traffic from one
place to another, but it's still your traffic.

## VPN Misconceptions ##

When people are new to the use of a VPN, there seems to be a lot of
misconceptions about how they're supposed to work and their properties.

### VPNs Change Your IP Address ###

VPNs do not change the public IP address of your computer.  While they do
usually assign a new private IP for the tunnel interface, this IP is one that
will never appear on the internet, so is not of concern to most users.  What
**it does** do is route your traffic via the tunnel so it emerges onto the
public internet from another IP address (belonging to your VPN server).

### VPN "Leaks" ###

Generally speaking, when someone refers to a VPN leak, they're referring to the
ability of a remote server to identify the public IP to which the endpoint is
directly attached.  For example, a server seeing the ISP-assigned IP address of
your computer as the source of incoming packets can be seen as a "leak".

These are not, generally, the fault of the VPN itself.  They are usually caused
by the routing rules your computer is using to determine how to send packets to
their destination.  You can test the routing rules with a command like:

```
% ip route get 8.8.8.8
8.8.8.8 dev wg0 table 51820 src 10.13.37.148 uid 1000
    cache
```

You can see that, in order to reach the IP `8.8.8.8` (Google's DNS server), I'm
routing packets via the `wg0` interface -- so out via the VPN.  On the other
hand, if I check something on my local network, you can see it will go directly:

```
% ip route get 192.168.20.1
192.168.20.1 dev wlp3s0 src 192.168.20.21 uid 1000
    cache
```

If you don't see the VPN interface when you run `ip route get <destination>`,
you'll end up with traffic *not* going via the VPN, and so going directly to
the destination server.  Using [ifconfig.co](https://ifconfig.co) to test the IP
being seen by servers, I'll examine the two scenarios:

```
% host ifconfig.co
ifconfig.co has address 104.28.18.94
% ip route get 104.28.18.94
104.28.18.94 dev wgnu table 51820 src 10.13.37.148 uid 1000
    cache
% curl -4 ifconfig.co
198.51.100.6
... shutdown VPN ...
% ip route get 104.28.18.94
104.28.18.94 via 192.168.20.1 dev wlp3s0 src 192.168.20.21 uid 1000
    cache
% curl -4 ifconfig.co
192.0.2.44
```

Note that my real IP (`192.0.2.44`) is exposed to the `ifconfig.co` service when
the route is not destined to go via the VPN.  If you see a route via your local
router to an IP, then that traffic is not going over a VPN client running on
your local host.

Note that routing DNS outside the VPN (e.g., to your local DNS server) provides
a trivial IP address leak.  By merely requesting a DNS lookup to a unique
hostname for your connection, the server can force an "IP leak" via DNS.  There
are other things that can potentially be seen as an "IP leak," like WebRTC.

### VPN Killswitches ###

A VPN "killswitch" is a common option in a 3rd party clients.  This endeavors to
block any traffic not going through the VPN, or block all traffic when the VPN
connection is not active.  This is **not** a core property of VPNs, but may be a
property of a particular VPN client.  (For example, this is not built in to the
official OpenVPN or Wireguard clients, nor the IPSec implementations for either
Windows or Linux.)

## VPN Routers ##

[![](//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=B07GBXMBQF&Format=_SL160_&ID=AsinImage&MarketPlace=US&ServiceVersion=20070822&WS=1&tag=systemovecom-20&language=en_US){:.right}](https://www.amazon.com/GL-iNet-GL-AR750S-Ext-pre-Installed-Cloudflare-Included/dp/B07GBXMBQF/ref=as_li_ss_il?dchild=1&keywords=ar750s&qid=1584922605&sr=8-1&linkCode=li2&tag=systemovecom-20&linkId=9a8b5318cbaf2828d144acdf67d84877&language=en_US")

One approach to avoiding local VPN configuration issues is to use a separate
router that puts all of the clients connected to it through the VPN.  This has
several advantages, including easier implementation of a killswitch, support for
clients that may not support VPN applications (e.g., smart devices, e-Readers,
etc.).  If configured correctly, it can ensure no leaks (e.g., by only routing
from its "LAN" side to the "VPN" side, and never from "LAN" to "WAN").

I do this when travelling with a [gl.inet AR750-S
"Slate"](https://amzn.to/3bfu8k3).  The stock firmware is based on OpenWRT, so
you can choose to run a fully OpenWRT custom build (like I do) or the default
firmware, which does support both Wireguard and OpenVPN.  (Note that, being a
low-power MIPS CPU, throughput will not match raw throughput available from your
computer's CPU, however it will still best the WiFi at the hotel or airport.

## VPNs are not a Panacea ##

Many people look for a VPN as an instant solution for privacy, security, or
anonymity.  Unfortunately, it's not that simple.  Understanding how VPNs work,
how IP addresses work, how routing works, and what your threat model is will
help you make a more informed decision.
