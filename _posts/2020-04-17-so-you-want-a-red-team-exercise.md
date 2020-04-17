---
layout: post
title: "So You Want a Red Team Exercise?"
category: Security
date: 2020-04-17
tags:
  - Security
  - Red Team
---

I originally wrote this for work, where we get a lot of requests to "Red Team"
*something*.  In a lot of these cases, a white box security review or other form
of security testing is more appropriate.  Because I'd heard through the
grapevine that other Red Teams struggle with the same issues, I wanted to make
it available publicly.  Thanks to my management for their support and permission
to take this public!

If you'd like to use or adapt this within your organization, feel free, but
please give credit to the Google Red Team.

---

We frequently get requests to perform Red Team engagements on various products &
services around our company. These requests often have misconceptions about the
services our team provides. This document is intended to help those seeking a
Red Team engagement have a better understanding of what we do, how we do it, and
why we do it the way we do, and how to engage with us for optimal effectiveness.

<!--more-->

## What is a Red Team Exercise?

A Red Team Exercise is a goal-oriented simulation of an attacker targeting a
part of our company. Within the constraints of our resources and rules of
engagement, we attempt to:

 * Emulate what real adversaries would do, with the purpose of testing our
   security controls and detection and response capabilities
 * Evaluate mechanisms attackers use to move laterally
 * Increase security awareness

We focus on realistic scenarios based on our understanding of the attacker
landscape and capabilities.

### What does Goal-Oriented Mean?

In conjunction with our threat intelligence and incident response teams, and
security advocates from around the company, we **identify particular data or
systems that a real world attacker would want to gain access to and could
feasibly attack successfully**.

Note: Our focus (like an attacker’s) is on the end goal and we will simulate the
most likely attack path to that goal. This means that if we can meet our
objective by stealing backups and never touching the service that generated that
data, we may approach it via that attack path. Attackers will follow the easiest
path within their risk tolerance of being discovered in order to meet their
objectives. This means that some vulnerabilities, systems, and processes are not
good candidates for a Red Team exercise simply because real world attackers are
unlikely to progress via that path when easier or lower risk paths exist.

### How does a Red Team compare to a Security Review or a Penetration Test?

A Red Team is complementary to a Security Review -- one does not substitute the
other.  Penetration tests are a sort of middle ground where vulnerabilities are
enumerated and tested, but generally without regard to attacker intent and
objective.  We do not currently conduct such penetration tests, as they don't
help us achieve our goal or mission.

|   | **Security Review** | **Penetration Test** | **Red Team** |
|---|---------------------|----------------------|--------------|
| **Primary Goal** | Review a single product/service in isolation to look for security bugs, weaknesses, or opportunities for hardening. Attempt to identify and address as many weaknesses as possible. | Attempt to enumerate vulnerabilities and potentially test the exploitability of them. | Achieve a particular goal in the same manner that an attacker would. Only attempt to identify weaknesses that further the attacker’s goals. |
| **Level of Knowledge** | White-box and transparent -- a security reviewer should have access to the source, documentation, etc. | Usually black box, but some insider knowledge may be used. | Attempts to only use information available to an attacker. |
| **Scope** | Single product/service. | Varies | Org-wide to get to the target/objective. |

### What does Adversary Emulation Mean?

We attempt to use the same Tactics, Tools, and Procedures (TTPs) that are
available to our attackers. We don’t always emulate the same attacker model --
sometimes we look at insider threats, sometimes it’s nation-state adversaries,
and sometimes it’s cybercrime groups. In each case, we endeavor to use only the
resources and TTPs that would be available to that attacker.

We simulate each part of the attack as though our company were actually getting
hacked:

* Reconnaissance: Gather information about the target from the internet
* Infiltration: Test and exploit systems or send phishing campaigns
* Lateral Movement: Move laterally through the network
* Exfiltration: Gather real or simulated “loot”, including corporate and user
  data.

Using this approach of simulating the entire attack makes the exercise a real
test of our controls, which has multiple benefits, including:

* Testing detection and response systems and processes against actual attacks
* Demonstrating the impact of an attack to leadership
* Helping prioritize the vulnerabilities or issues to tackle, depending on which
  are most beneficial to attackers

## Preparing for a Red Team

If you feel a Red Team is appropriate for your concerns, please review the
considerations below and provide the requested information.

### Have you had a Security Review?

We strongly recommend having undergone a Security Review before a Red Team.
Security Reviews are scoped to the single service rather than the larger
ecosystem, will try to find a breadth of issues instead of going deep into a
small number of issues, and can help inform the threat model for the Red Team.

### Planning the Engagement -- Threat Model

Consider the following questions when requesting a Red Team engagement. Your
answers help us figure out the optimal plan for the engagement.

1. What data or access is the adversary hoping to acquire? This helps us
   determine the objective.
2. Who is going to be attacking us? Is it an insider, cyber criminals, nation
   state adversaries, etc.?
3. What resources are they willing to use for this exercise? Is it worth the use
   of 0-day exploits, or just basic phishing?
4. What other products or services might an attacker consider to get to the same
   outcome?
5. What is the impact to our company of an attacker gaining this access?
