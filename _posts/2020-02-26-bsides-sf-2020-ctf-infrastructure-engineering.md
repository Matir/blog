---
layout: post
title: "BSides SF 2020 CTF: Infrastructure Engineering and Lessons Learned"
category: Security
date: 2020-02-27
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

<!--more-->

* Contents
{:toc}

## About the CTF

This year we ran 48 challenges for 175 teams (that scored at least one flag)
over a period of 31 hours.  Approximately 1/3 of the teams were onsite, and the
rest were remote.

## Challenge Quality

Let me start with the biggest positive of 2020: challenge quality.  While there
were a couple of snags (wrong libc uploaded to scoreboard, for example), all of
the challenges were solvable in the production environment, we did a good job of
avoiding "guessy" challenges, and the challenges were a variety of difficulties.
We've also received overall very positive feedback from players about the
challenges.

## Infrastructure Overview

Our infrastructure was sponsored by the Google Security Team (disclaimer: I'm a
member of that team) and consequently was hosted on [Google
Cloud](https://cloud.google.com/).  All challenges were built in containers and
hosted in a single Kubernetes cluster, the scoreboard was served by AppEngine,
and the backend database by CloudSQL.  In general, this worked quite well.
Those writing challenges did not have to worry much about the infrastructure, as
we used tools to write all of the Kubernetes configurations for us.

I have plans to clean up (actually, probably rewrite) the tools we used to
manage our deployments and infrastructure so that others may use them.  I'd
really love to see a portable way of defining CTF challenges as Docker
containers so that others can reuse the challenges.  While challenge reuse poses
problems for "competitive" CTFs, I think they can be a great skill builder for
CTF teams, those new to security, or people running small informal CTFs in their
hackerspace or local DEF CON group.

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

It's always a challenge to balance things between our on-site (conference)
players and those playing remotely.  We want to be able to build non-traditional
challenges that require being onsite, such as "Locky", our lockpicking challenge
that prints a physical flag for players, or a challenge to unlock an onsite
simulated smart lock.

We also aren't able to provide around-the-clock support online because of the
conference schedule, activities, and our location.  Likewise, our timing this
year was a match to the conference schedule, which we realize is inconvenient
for some of our remote players because of differing timezones.

We've gone back and forth on listing our CTF as "onsite" vs "online" on CTFTime.
We went "onsite" this year because of the number of onsite-only challenges we
featured, but we believe that resulted in lower participation from online teams.

## Introductory Challenges

Historically, I feel that we've done a good job of providing introductory
challenges for players.  (We usually term these "101s".)  This year, we fell
*way* short on that, and for that, I apologize.  A good conference CTF should be
accessible to people of a variety of skill levels, should provide activities
that don't occupy your whole day, and that teach new things to help attendees
build their skill set.  We came up with so many "clever" challenges that we let
101s fall by the wayside and only provided a scant few.  Sorry to the players
this year, but we've heard your feedback.

## "Dynamic" Scoring

For the first time in our CTF, we used dynamic scoring.  The value of a
challenge was not fixed at some arbitrary number we determined in advance, but
was based on the number of teams that solved a challenge (as a reasonable proxy
for difficulty).  I'm happy with how the scoring worked, but some teams were
confused by it.  Some teams believed they would receive the number of points
the challenge was worth at the time they solved it, versus the changing number
of points as more teams solved the challenge.

## Plans for Next Year

All of these plans are subject to change, so please take what I'm writing with a
grain of salt.  :)  However, if you have strong feelings about them, feel free
to [reach out](https://twitter.com/Matir).

### Onsite vs Remote

We want to continue to provide unique challenges that require being onsite for
several reasons:

1. It's a conference CTF, so providing unique content for conference attendees
   makes sense.
2. There are certain things that can only be done onsite (like lockpicking) and
   we enjoy incorporating these elements.
3. It helps distinguish us from other CTFs.

At this point, our plan is to have teams categorize as "onsite" vs "online", and
continue to award the conference prizes to teams physically at the conference.
We'll continue to have onsite-only challenges, but those **will be omitted from
the scoreboard we upload to CTFTime**.  This will ensure that the challenges
considered for placement on CTFTime are accessible to *all* teams, but still
allow us to provide the unique challenges and experiences for our onsite teams.

We're also considering to return to a 48-hour CTF, beginning ~48 hours before
the closing ceremonies of the conference, in order to be fair and equitable to
online players around the world.  It still won't be perfect with the weekend
alignment, but that's controlled by the conference, not us.

### 101s

We're planning to add true 101-level challenges.  We want to plan topics in
advance and provide challenges with enough obviousness that someone new to the
topic can solve it in an hour or two.  These will likely come with built-in
hints, as the primary goal will be education, not competition.  Experienced
teams will, of course, be able to solve these as well, but we expect their point
value to be quite low, so unlikely to have a major effect on outcome.

### Unchanged Elements

We'll likely be using k8s on some platform again for our infrastructure.  It
makes so much sense for running a Jeopardy-style CTF.  Because of the high level
of tweaking we do to the scoreboard, it'll probably be the same scoreboard
software, but hopefully I'll find time to give it some love in between years.

Our scoring will likely be similar -- the dynamic scoring worked well from what
we expected, and some challenges we thought were hard turned out not to be so
hard and vice-versa.  We will make an effort to better communicate how the
scoring works, however.

We will still only plan to have support during conference hours.  We're a small
team and we all want to enjoy the con and the parties too.
