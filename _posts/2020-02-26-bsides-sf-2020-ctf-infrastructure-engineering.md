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
and the backend database by CloudSQL.

### Using Kubernetes

### Kubernetes Security

### AppEngine

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

## Balancing On-Site and Remote Participants

## Plans for Next Year
