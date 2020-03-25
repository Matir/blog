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

### Parsing Headers ###

### Running a Proxy ###

### Running an Application ###
