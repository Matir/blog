---
layout: post
title: "VPS Upgrade"
date: 2014-04-23 14:14:25 +0000
permalink: /2014/04/23/vps-upgrade/
category: Linux
tags:
  - Linode
  - VPS
---
As [I've mentioned before](/2011/05/18/linode-rocks/),
my blog is hosted on a VPS at
[Linode](http://www.linode.com/?r=680a893e24df3597d32f58cd41930e969027dc06).
Just under 3 years ago, I moved to my current VPS in their Newark DC to take
advantage of their native IPv6 support.  I've now moved within Linode again,
this time to take advantage of their [awesome free
upgrades](https://blog.linode.com/2014/04/17/linode-cloud-ssds-double-ram-much-more/).

$20/month gets you a 2GB Xen VM backed by enterprise-grade SSDs, Ivy Bridge
Xeons, and a 40Gbps backbone.  Think that 40Gbps is going to waste?  Think
again.  I downloaded a 100MB test file from Cachefly in **1.2 seconds**.  That's
**85.5 MB/s**.  Consider my mind blown.

I've been a Linode customer since 2009, and have probably had about 3 outages in
the 5 years.  All have been short, and have had good explanations with great
communication from the Linode staff.  There may be cheaper options out there,
but I care about uptime and infrastructure, and Linode makes the necessary
investments there.

Full ApacheBench tests for my old and new hardware are below.

#### 32 bit VM on Old Hardware ####
    % ab -c 10 -n 200 -q https://epsilon.systemoverlord.com/
    This is ApacheBench, Version 2.3 <$Revision: 1430300 $>
    Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
    Licensed to The Apache Software Foundation, http://www.apache.org/

    Benchmarking epsilon.systemoverlord.com (be patient).....done


    Server Software:        nginx/1.2.1
    Server Hostname:        epsilon.systemoverlord.com
    Server Port:            443
    SSL/TLS Protocol:       TLSv1.1,ECDHE-RSA-RC4-SHA,2048,128

    Document Path:          /
    Document Length:        26 bytes

    Concurrency Level:      10
    Time taken for tests:   7.878 seconds
    Complete requests:      200
    Failed requests:        0
    Write errors:           0
    Non-2xx responses:      200
    Total transferred:      121600 bytes
    HTML transferred:       5200 bytes
    Requests per second:    25.39 [#/sec] (mean)
    Time per request:       393.898 [ms] (mean)
    Time per request:       39.390 [ms] (mean, across all concurrent requests)
    Transfer rate:          15.07 [Kbytes/sec] received

    Connection Times (ms)
                  min  mean[+/-sd] median   max
    Connect:      277  298  17.6    292     386
    Processing:    89   93   4.3     92     112
    Waiting:       87   93   4.1     91     112
    Total:        367  391  17.7    387     481

    Percentage of the requests served within a certain time (ms)
      50%    387
      66%    393
      75%    398
      80%    401
      90%    414
      95%    426
      98%    448
      99%    458
      100%    481 (longest request)

#### 64-bit VM on New Hardware ####
    % ab -c 10 -n 200 -q https://lambda.systemoverlord.com/
    This is ApacheBench, Version 2.3 <$Revision: 1430300 $>
    Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
    Licensed to The Apache Software Foundation, http://www.apache.org/

    Benchmarking lambda.systemoverlord.com (be patient).....done


    Server Software:        nginx/1.2.1
    Server Hostname:        lambda.systemoverlord.com
    Server Port:            443
    SSL/TLS Protocol:       TLSv1.1,ECDHE-RSA-RC4-SHA,2048,128

    Document Path:          /
    Document Length:        26 bytes

    Concurrency Level:      10
    Time taken for tests:   2.999 seconds
    Complete requests:      200
    Failed requests:        0
    Write errors:           0
    Non-2xx responses:      200
    Total transferred:      121600 bytes
    HTML transferred:       5200 bytes
    Requests per second:    66.68 [#/sec] (mean)
    Time per request:       149.959 [ms] (mean)
    Time per request:       14.996 [ms] (mean, across all concurrent requests)
    Transfer rate:          39.59 [Kbytes/sec] received

    Connection Times (ms)
                  min  mean[+/-sd] median   max
    Connect:       68   90  21.8     84     199
    Processing:    22   57 100.4     31     623
    Waiting:       20   57 100.3     30     623
    Total:         95  148 105.4    115     707

    Percentage of the requests served within a certain time (ms)
      50%    115
      66%    120
      75%    128
      80%    143
      90%    212
      95%    479
      98%    566
      99%    706
      100%    707 (longest request)

