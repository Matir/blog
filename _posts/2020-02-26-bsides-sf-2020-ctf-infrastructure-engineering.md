---
layout: post
title: "BSides SF 2020 CTF: Infrastructure Engineering and Lessons Learned"
category: Security
date: 2020-02-26
tags:
  - BSidesSF
  - CTF
---

Last weekend, I had the pleasure of running the BSides San Francisco CTF along
with friends and co-conspirators [c0rg1](https://twitter.com/itsc0rg1),
[symmetric](https://twitter.com/bmenrigh) and
[iagox86](https://twitter.com/iagox86).  This is something like the 4th or 5th
year in a row that I've been involved in this, and every year, we try to do a
better job than the year before, but we also try to do new things and push the
boundaries.  I'm going to review some of the infrastructure we used, challenges
we faced, and lessons we learned for next year.

* Contents
{:toc}

## About the CTF

This year we ran 48 challenges for 175 teams (that scored at least one flag)
over a period of 31 hours.  Approximately 1/3 of the teams were onsite, and the
rest were remote.  XXX flags were submitted in total.

## Infrastructure Overview

Our infrastructure was sponsored by the Google Security Team (disclaimer: I'm a
member of that team) and consequently was hosted on [Google
Cloud](https://cloud.google.com/).  All challenges were built in containers and
hosted in a single Kubernetes cluster, the scoreboard was served by AppEngine,
and the backend database by CloudSQL.  In general, this worked quite well.
Those writing challenges did not have to worry much about the infrastructure, as
we used tools to write all of the Kubernetes configurations for us.

### Using Kubernetes

All of the challenges ran within our Kubernetes cluster in GKE.  Most challenges
were a single container in their pod, but some had multiple containers.  Many
web challenges made use of a "webbot" that was a headless browser to allow
players to exploit Cross-Site Scripting and other similar challenges.  Some
challenges required a database backend and so we ran the CloudSQL proxy in the
pod as a sidecar container.

Most challenges were run with 3 replicas each.  Web challenges sat behind a
single HTTPS Ingress that terminated TLS using a wildcard certificate from Let's
Encrypt, while TCP challenges each used their own Kubernetes LoadBalancer to
distribute incoming connections.

### Kubernetes Security

In 2017,
[we had some issues](https://hackernoon.com/capturing-all-the-flags-in-bsidessf-ctf-by-pwning-our-infrastructure-3570b99b4dd0)
with running our infrastructure due to the default security configuration of
Kubernetes.  A *lot* has changed in 3 years, and (as far as we know) the
infrastructure withstood the onslaught of the players.

We took several significant steps to harden the infrastructure this year:

1. We [disabled
   mounting](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)
   of the Service Account tokens within the pods.
2. We restricted the GCE service account used for the to only a minimum set of
   permissions.  This specifically included the ability to write Stackdriver
   logs and metrics, and read from the GCS storage buckets that contained the
   container images for the challenges.  This ensured that a service account
   token leak would have minimal impact.
3. We enabled [Workload
   Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity),
   a new feature for GKE that gives the Kubernetes Service Account its own
   identity and access tokens.  By default, this identity has no privileges
   (unless you bind the KSA to a GSA) so the token doesn't allow a malicious
   actor to do anything.  It also replaces requests to the GCE Metadata Server
   with a special GKE Metadata Server, similar to [metadata
   concealment](https://cloud.google.com/kubernetes-engine/docs/how-to/protecting-cluster-metadata).
4. We enabled a [Kubernetes network
   policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
   that prevented challenge pods from reaching each other.
5. We also ran each challenge as a non-root user (usually `ctf`), and also ran
   with an [AppArmor and
   seccomp](https://kubernetes.io/docs/concepts/policy/pod-security-policy/)
   policy in place.  This mitigated the risk of a container escape (though these
   are probably unlikely to see in a CTF).

### AppEngine

Using AppEngine for the frontend allows for easy horizontal scaling of the
scoreboard.  The instances can go up and down as needed to handle load, though
there can be some side effects (see below).  The AppEngine runtime also offers a
high level of isolation between the scoreboard and the challenges themself.  The
scoreboard points at a CloudSQL backend, configured for High Availability and
with automated backups.  This provides a high level of resiliency in case
there's an issue with the database.

### Scoreboard Issues

The [scoreboard](https://github.com/google/ctfscoreboard) had a couple of issues
this year due to some last minute changes.  In one case, there was an API call
that was running slowly, so I thought I would "improve" things with a live code
change.  I consequently managed to take out the entire scoreboard for ~60
minutes.  (Sorry everyone!)

The original API request resulted in one database query that returned joined
records of all the teams and all of their submissions.  It then did N queries
(one per team) to get their scoring history for the score graph.  My "fix" was
to translate this to a single joined query across all 3 tables.  For those of
you unfamiliar with a 3-way join like this, that blows up the number of results
dramatically.  In this case, the results became something like 7.5 *million*
rows, requiring 10s of seconds for the frontend to finish streaming from the
backend and translating into objects via its ORM.  (SQLAlchemy)

The delays from these slow responses resulted in AppEngine scaling up the number
of frontend instances dramatically (reaching ~175 front end instances at one
point), most of which were issuing the same requests to the database server.
This lead to further slowdown of the database server.  Eventually, the database
server was pegged at 100% CPU and RAM and all queries came to a full and
complete halt.  Frontends then began falling over with connection limits and
errors and the scoreboard was essentially dead.

It took some time to diagnose the cause of this, and stopgap measures like
upsizing the database did not resolve the issue.  Eventually, I needed to roll
back the change, downsize the frontends, and restart the database server to
clear the queue of queries.  This brought the scoreboard back to life, but it
did cause some inconvenience for players.

The performance issue was made worse by the fact that the AppEngine Python 3.7
runtime no longer supports Memcache, so we were running without a frontend cache
to reduce load and continue to provide responses for some requests.  A
Redis-based cache is in the cards to improve this situation as well.

## Balancing On-Site and Remote Participants

## Plans for Next Year
