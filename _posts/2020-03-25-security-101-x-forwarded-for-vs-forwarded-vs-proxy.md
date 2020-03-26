---
layout: post
title: "Security 101: X-Forwarded-For vs. Forwarded vs PROXY"
category: Security
date: 2020-03-25
tags:
  - Security 101
  - Networking
---
Over time, there have been a number of approaches to indicating the original
client and the route that a request took when forwarded across multiple proxy
servers.  For HTTP(S), the three most common approaches you're likely to
encounter are the `X-Forwarded-For` and `Forwarded` HTTP headers, and the `PROXY
protocol`.  They're all a little bit different, but also the same in many ways.

## X-Forwarded-For ##

`X-Forwarded-For` is the oldest of the 3 solutions, and was probably introduced
by the Squid caching proxy server.  As the `X-` prefix implies, it's not an
official standard (i.e., an IETF RFC).  The header is an HTTP multi-valued
header, which means that it can have one or more values, each separated by a
comma.  Each proxy server should append the IP address of the host from which it
received the request.  The resulting header looks something like:

```
X-Forwarded-For: client, proxy1, proxy2
```

This would be a request that has passed through **3** proxy servers -- the IP of
the 3rd proxy (the one closest to the application server) would be the IP seen
by the application server itself.  (Often referred to as the "remote address" or
`REMOTE_ADDR` in many application programming contexts.)

So, you could end up seeing something like this:

```
X-Forwarded-For: 2001:DB8::6, 192.0.2.1
```

Coming from a TCP connection from `127.0.0.1`.  This implies that the client had
IPv6 address `2001:DB8::6` when connecting to the first proxy, then that proxy
used IPv4 to connect from 192.0.2.1 to the final proxy, which was running on
localhost.  A proxy running on localhost might be nginx splitting between static
and application traffic, or a proxy performing TLS termination.

## Forwarded ##

The HTTP `Forwarded` header was standardized in [RFC
7239](https://tools.ietf.org/html/rfc7239) in 2014 as a way to better express
the `X-Forwarded-For` header and related `X-Forwarded-Proto` and
`X-Forwarded-Port` headers.  Like `X-Forwarded-For`, this is a multi-valued
header, so it consists of one or more comma-separated values.  Each value is,
itself, a set of key-value pairs, with pairs separated by semicolons (`;`) and
the keys and values separated by equals signs (`=`).  If the values contain any
special characters, the value must be quoted.

The general syntax might look like this:

```
Forwarded: for=client, for=proxy1, for=proxy2
```

The key-value pairs are necessary to allow expressing not only the client, but
the protocol used, the original HTTP `Host` header, and the interface on the
proxy where the request came in.  For figuring out the routing of our request
(and for parity with the `X-Forwarded-For` header), we're mostly interested in
the field named `for`.  While you might think it's possible to just extract this
key-value pair and look at the values, the authors of the RFC added some extra
complexity here.

The RFC contains provisions for "obfuscated identifiers."  It seems this is
mostly intended to prevent revealing information about internal networks when
using forward proxies (e.g., to public servers), but you might even see it in
operating reverse proxies.  According to the RFC, these should be prefixed by an
underscore (`_`), but I can imagine cases where this would not be respected, so
you'd need to be prepared for that in parsing the identifiers.

The RFC *also* contains provisions for unknown upstreams, identified as
`unknown`.  This is used to indicate forwarding by a proxy in some manner that
prevented identifying the upstream source (maybe it was through a TCP load
balancer first).

Finally, there's also the fact that, unlike the defacto standard of
`X-Forwarded-For`, `Forwarded` allows for the *option* of including the port
number on which it was received.  Because of this, IPv6 addresses are enclosed
in square brackets (`[]`) and quoted.

The example from the `X-Forwarded-For` section above written using the
`Forwarded` header might look like:

```
Forwarded: for="[2001:DB8::6]:1337", for=192.0.2.1;proto=https
```

Additional examples taken from the RFC:

```
Forwarded: for="_gazonk"
Forwarded: For="[2001:db8:cafe::17]:4711"
Forwarded: for=192.0.2.60;proto=http;by=203.0.113.43
Forwarded: for=192.0.2.43, for=198.51.100.17
```

## PROXY Protocol ##

At this point, you may have noticed that both of these headers are HTTP headers,
and so can only be modified by L7/HTTP proxies or load balancers.  If you use a
pure TCP load balancer, you'll lose the information about the source of the
traffic coming in to you.  This is particularly a problem when forwarding HTTPS
connections where you don't want to offload your TLS termination (perhaps
traffic is going via an untrusted 3rd party) but you still want information
about the client.

To that end, the developers of [HAProxy](https://www.haproxy.org/) developed the
[PROXY protocol](https://www.haproxy.org/download/1.8/doc/proxy-protocol.txt).
There are (currently) two versions of this protocol, but I'll focus on the
simpler (and more widely deployed) 1st version.  The proxy should add a line at
the very beginning of the TCP connection in the following format:

```
PROXY <protocol> <srcip> <dstip> <srcport> <dstport>\r\n
```

Note that, unlike the HTTP headers, this makes the PROXY protocol *not*
backwards compatible.  Sending this header to a server not expecting it will
cause things to break.  Consequently, this header will be used exclusively by
reverse proxies.

Additionally, there's no support for information about the hops along the way --
each proxy is expected to maintain the same PROXY header along the way.

Version 2 of the PROXY protocol is a binary format with support for much more
information beyond the version 1 header.  I won't go into details of the format
(check the spec if you want) but the core security considerations are much the
same.

## Security Considerations ##

If you need (or want) to make use of these headers, there are some key security
considerations in *how* you use them to use them safely.  This is *particularly*
of consideration if you use them for any sort of IP whitelisting or access
control decisions.

Key to the problem is recognizing that the headers represent **untrusted
input** to your application or system.  Any of them could be forged by a client
connecting, so you need to consider that.

### Parsing Headers ###

After I spent so long telling you about the format of the headers, here's where
I tell you to disregard it all.  Okay, really, you just need to be prepared to
receive poorly-formatted headers.  Some variation is allowed by the
specifications/implementations: optional spaces, varying capitalization, etc.
Some of this will be benign but still unexpected: multiple commas, multiple
spaces, etc.  Some of it will be erroneous: broken quoting, invalid tokens,
hostnames instead of IPs, ports where they're not expected, and so on.

None of this, however, precludes malicious input in the case of these headers.
They may contain attempts at [SQL
Injection](https://owasp.org/www-community/attacks/SQL_Injection),
[Cross-Site Scripting](https://owasp.org/www-community/attacks/xss/) and other
malicious content, so one needs to be cautious in parsing and using the input
from these headers.

### Running a Proxy ###

As a proxy, you should consider whether you expect to be receiving these headers
in your requests.  You will only want that if you are expecting requests to be
forwarded from another proxy, and then you should make sure the particular
request *came from* your proxy by validating the source IP of the connection.
As untrusted input, you **cannot** trust any headers from proxies not under your
control.

If you are **not** expecting these headers, you should drop the headers from the
request before passing it on.  Blindly proxying them might cause downstream
applications to trust their values when they come from your proxy, leading to
false assertions about the source of the request.

Generally, you should rewrite the appropriate headers at your proxy, including
adding the information on the source of the request to your proxy, before
passing them on to the next stage.  Most HTTP proxies have easy ways to manage
this, so you don't usually need to format the header yourself.

### Running an Application ###

This is where it gets particularly tricky.  If you're using IP addresses for
anything of significance (which you probably shouldn't be, but it's likely
there's some cases where people still are), you need to figure out whether you
can trust these headers from incoming requests.

First off, if you're not running the proxies: **just don't trust them.**  (Of
course, I count a managed provider as run by you.)  Also,
if you're not running the proxy, I hope we're only talking about the PROXY
protocol and you're not exposing plaintext to untrusted 3rd parties.

If you are running proxies, you need to make sure the request actually came from
one of your proxies by checking the IP of the direct TCP connection.  This is
the "remote address" in most web programming frameworks.  If it's not from your
proxy, then you **can't trust the headers.**

If it's your proxy and you made sure not to trust incoming headers in your proxy
(see above), then you can trust the full header.  Otherwise, you can only trust
the incoming hop to your proxy and anything before that is not trustworthy.

### Man in the Middle Attacks ###

All of this disregards MITM attacks of course.  If an attacker can inject
traffic and spoof source IP addresses into your traffic, all bets on trusting
headers are off.  TLS will still help with header integrity, but they can still
spoof the source address, convincing you to trust the headers in the request.

### Bug Bounty Tip ###

Try inserting a few headers to see if you get different responses.  Even if you
don't get a full authorization out of it, some applications will give you debug
headers or other interesting behavior.  Consider some of the following:

```
X-Forwarded-For: 127.0.0.1
X-Forwarded-For: 10.0.0.1
Forwarded: for="_localhost"
```
