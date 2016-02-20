---
layout: post
title: BSides Seattle
date: 2016-02-20
category: Security
tags: BSides Seattle, BSides, Security
---

These are just (essentially) my raw notes dumped from the talks I attended at
BSides Seattle (2015-ish).

### Active Directory ###

- Use scripts to dump AD
- Use scripts to sync with 3rd party providers
- Lots of story, not much technical depth

### Red Team ###

- Presenter: Sean Malone, FusionX

- Types of Security Assessment
  - Vulnerability Assessment
    - Find vulnerability
    - Limited Scope
    - Broad & Shallow
    - Cooperates with SecOps
  - Pentesting
    - Achieve Technical Compromise/Domain Admin
    - Moderate Depth
    - Techniques include Network, Application Assessment
  - Red Team
    - Narrow Scope
    - Whole Enterprise is In Scope
    - Techniques include Social, Physical, Technical
    - RT Objectives
      - Simulate Sophisticated Adversary
      - Achieve "Nightmare Scenario" without detection
    - Client Objectives
      - Understand resiliency
      - Risk reduction, not just vulnerability count
- Effective Red Teams
  - Hyper-realism (go all the way)
  - Do No Harm
  - Zero-Knowledge
    - Offensive team does not use any inside knowledge
  - Zero-Notice
    - No notice to defensive team
- Developing Steps
  - Adversary Scenario
    - Who?
      - Nation-state?
      - Commercial Competitor?
      - Hacktivist?
    - Why?
      - Steal information?
      - Destabilize?
    - Impact
    - Objective
    - Starting Point
  - Campaign Plan
    - Be Creative
      - Wide Variety of Approaches
      - Webapps
      - USB Drives
      - Social Networking
      - Legal limits: can't bribe someone, can't blackmail someone, etc.
    - Be Adaptive
      - Can't know how everything will go
      - May have several different approaches planned out, use as needed
    - Be Resilient
      - Even if detected, engagement is not over
      - Keep different techniques/footholds isolated
    - Even if technique is known to work (phishing, link clicking, social
      engineering), there is value in doing it
      - Is it detected?
      - Can mitigations come into place in time to prevent lateral
        movement/escalation?
  - Scope
    - Think Globally, Strike Precisely
    - Whole Enterprise in Scope
    - Stay Focused
      - Only move towards objective
      - May not be linear path, but still move to goal
      - Exploiting unnecessarily increases risk of detection
    - Right to Audit clause in Vendor Agreements Critical
    - Client should not limit scope
      - Confirmation bias
      - If concerned about availability, pretty big sign that system is already
        too weak
      - Forcing red team into small box does *not* simulate adversaries
  - Rules of Engagement
    - Should not need to get pre-approval for every exploit/phishing email/etc.
    - RoE should allow autonomy to exploit, move laterally, and escalate
    - Client should still be informed, have ability to push "big red button",
      but red team should not wait for ACK (too slow)
    - Attacker should have 24x7 window (again, better simulates real-world
      adversary)
      - Vulnerability in timing is just another vulnerability
    - Predefined rules for sensitive data
      - Access is necessary to simulate adversary; avoid unrealistic limitation
        that impacts the accuracy of the assessment
      - Expectation should be that Red Team may see any data on any system (IP,
        passwords, HR data, whatever)
      - Rules for what can be used (i.e., personal credentials generally
        off-limits)
      - Rules for how to dispose of data at end of engagement
      - Rules for where data can be moved (i.e., shipping PII outside network?)
      - Retrieve minimum number of records to demonstrate impact
      - Redact in report
  - Communication & Escalation Plan
    - Need-to-Know Basis
      - Statement of Work vague, have separate authorization signed by CISO to
        avoid leaking even to procurement team
    - Keep Blue Team in the dark (adversaries don't call ahead!)
      - Can't accurately evaluate detection & response if they know
      - Point of Contact should have visibility into SOC
      - If SOC is overwhelmed by exercise (+ real intrusion?), suspend exercise
- Summary
  - Only executive has authority to approve something broad enough
  - Technical compromise doesn't matter if you can't show impact
  - Stay focused
  - Maintain OpSec
  - Keep objective in mind
  - Risk/Reward to get closer to objective
  - Agile, Adaptive, Opportunistic
