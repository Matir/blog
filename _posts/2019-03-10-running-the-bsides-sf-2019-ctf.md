---
layout: post
title: "Running the BSides SF 2019 CTF"
category: Security
date: 2019-03-10
tags:
  - CTF
  - BSidesSF
---
## The Event ##

This year, I had the privilege to lead the team for the BSides San Francisco
CTF.  We had 1112 active players on 676 teams over the 32 hour CTF.
Collectively, 2740 flags were submitted to 41 of our 43 challenges.  So far, the
[CTFTime ratings](https://ctftime.org/event/753/weight/) have been excellent,
and I hope we'll be able to do that again.

<!--more-->

Before I go any further, I want to give kudos to my entire team:

- [iagox86](https://twitter.com/iagox86)
- [c0rg1](https://twitter.com/itsC0rg1)
- [symmetric](https://twitter.com/bmenrigh)
- [bryane](https://twitter.com/cornflakesavage)
- [exploitexercise](https://twitter.com/exploitexercise)

This would not have been possible without all their efforts.  I also want to
give a special shoutout to Puneet, who handled all the physical logistics for us
so we could focus on building the CTF.

## The Infrastructure ##

(Full disclosure: I'm a member of the Google Information Security Team.)

We were running [the scoreboard](https://github.com/google/ctfscoreboard) I
originally wrote for the Google CTF (though it's no longer used for that
purpose), hosted on [Google AppEngine](https://cloud.google.com/appengine/).  I
love hosting apps on a runtime like that -- the scaling and replication is just
magic, so we didn't have the typical latency spike a lot of CTFs do at the very
beginning.  95th percentile latency remained under 500ms, which is a result I'm
very happy with.

![Traffic](/img/blog/bsidessf2019/sb_traffic.png)

All of the online challenges were run on Kubernetes on [Google Cloud
Platform](https://cloud.google.com/) (for the 3rd year straight).
We continue to love this option, because we run Docker locally for building &
testing challenges, then transform these images straight to Kubernetes.
Additionally, Kubernetes provides capabilities like load balancing that allow us
to scale challenges up when some people feel the need to try to brute force.

This year, for the first time, we attempted to use Network Policies to prevent
access to the GCP metadata API, which worked, until I inadvertantly deleted the
policies while debugging an issue with another challenge.  Fortunately, I don't
believe this was exploited during the CTF, but I did notice some exploitation
attempts after the game.

Another first for this year was the use of an `Ingress` for all of our HTTP
services.  We used a wildcard certificate from Let's Encrypt and then performed
distribution to backends based on the hostname provided by the client.  This
allowed us to use a single external IP, easily provide HTTPS for the challenges,
and also provided load balancing for the challenges.

All of this infrastructure comes with some difficulties compared to just
spinning up a bunch of VMs.  First off, there's layers of complexity, like the
load balancers and the pods that contain containers.  There's multiple backends,
so if only one is acting up, it's harder to debug.  Additionally, for anything
with load balancing, it either needs to be stateless, or you need a way to sync
the state.  (IP load balancing might work, except we had a large portion of our
players coming from the one IP on site.)

[Google Cloud](https://cloud.google.com/) was nice enough to give us credits to
run all of our infrastructure, so big thanks to them for making this possible
for over 1100 players.  Questions about how we ran this?  Reach out to me on
[Twitter](https://twitter.com/matir).
