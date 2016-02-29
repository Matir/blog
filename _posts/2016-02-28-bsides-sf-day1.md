---
layout: post
title: "BSides SF: Saturday"
date: 2016-02-28
category: Security
---

Much like my notes from BSides Seattle, this will just be a quick dump of notes
from the talks I attended today.  (Almost) all talks are also being recorded by
Irongeek, so this only serves to highlight what I considered key points of the
talks I attended.  Tomorrow, I'll be doing my workshop (stop by and say hi) so
my notes are likely to be considerably lighter.

### Keynote: A Declaration of the Independence of Cyberspace ###

  *John Perry Barlow, co-founder, EFF*

While not at all a technical talk, John Perry Barlow is an inspiring speaker and
an amazing visionary.  His appreciation of the politics involved in "cyberspace"
is on point, and it really made me think.

While he first related the story of the events leading up to the founding of the
[EFF](https://www.eff.org/), including the writing of the
[Declaration of the Independence of Cyberspace](https://www.eff.org/cyberspace-independence),
but to my mind, the most interesting part of his keynote was the Q&A.

* **What does it mean to be patriotic in cyberspace?**
  * First have to define patriotism in general.
    * JPB defines as "allegiance to a common belief system"
  * The biggest threat is dismantling the common belief system under the guise
    of patriotism: as in the erosion of the bill of rights, etc.
  * The government is currently fighting for cultural dominance
    * It's a battle that's beeen going since the mid-60s, government powers are
      stuck in the 50s, the cold war, etc.
    * Government doesn't adapt to times well
    * 60s culture is slowly winning, but still not certain
* **How can we create more awareness of the EFF in young professionals & CS students?**
  * That's a really tough question, and if I [JPB] had the answer, the EFF would
    already be doing it.
  * However, informed individuals sharing the information helps.
  * EFF will continue defending the open network end-to-end.

### Scan, Pwn, Next! – exploiting service accounts in Windows networks ###

  *Andrey Dulkin, Matan Hart, CyberArk Labs*

* Service Accounts have a variety of properties that make them interesting to an
  attacker
  * May not have password complexity/expiration
  * Often overprivileged as privileges may be granted to try to fix a problem,
    even if not needed
  * Account may be used on multiple machines, exposing the credentials more
* Account types
  * Out accounts: automated processes, reach out to others
  * In accounts: listening services
  * Mixing an account into both types makes lateral movement trivial (compromise
    service, use to move to other box)
* Service principal name (SPN)
  * Created Automatically
  * Password hash used as shared secret
* Any user can request a ticket to any SPN
  * Encrypted with unsalted RC4 by default, key is NTLM hash of SPN password
  * Can be configured to use AES-128 or AES-256
  * Hashcat can offline crack the ticket to recover plaintext password
    * 7 mixed case alphanumerics takes about 10 hours on single GPU

### Breaking Honeypots for Fun and Profit ###

  *Itamar Sher, Cymmetria*

* Can be used to introduce the "fog of war" aspect
* OODA loop: Observe, Orient, Detect, Act
* Honeypots also serve as a decoy
* Several general types
  * Low interaction
    * Useful mainly for malware & scanning detection
    * Can be easily fingerprinted
  * High Interaction
    * Real machine
    * Heavily instrumented
* Only thing worse than an ambush that fails is an ambush that is detected by
  the adversary
  * Can be used to distract incident responders
  * Can be used to send malicious/misleading data
  * Constants are easily detected (e.g., conpot)
* Artillery Honeypot
  * low interaction
  * Blocks IP
  * Spoofing leads to DoS
* Kippo
  * Medium interaction
  * Allows some simulated commands
  * Team is good at fixing issues
  * wget allowed now
    * Could be used for DDoS
    * or portscanning/host enumeration
* Dronaea
  * Low interaction
  * Goal is to gain copy of malware
* General Problems
  * Fixed values
    * Build dates
    * Sizes
    * Names
    * Serial numbers
    * etc.
  * Partially implemented services
    * missing implementations of most commands
  * Users that respond to multiple passwords

### IoT on Easy Mode (Reversing Embedded Devices) ###

  *[Elvis Collado](http://b1ack0wl.com/)*

30 minute speed talk on reverse engineering & exploiting vulnerabilities in
embedded devices.

* Useful things:
  * Binwalk
  * IDA
  * Radare2
* Use Qemu, build basic source in C, disassemble to understand assembly of
  architecture
  * Use breakpoints to understand what particular instructions do (break,
    before/after comparison)
* GPL to see plain source
* Beginning kit
  * FT232H adapter
  * Multimeter
  * Soldering Iron
    * Solder
    * Wick
    * Desoldering pump
  * Header pins
  * wire
* Intermediate kit
  * (Beginning +)
  * Shikra
  * JTAGulator
  * Logic Analyzer
  * USB Microscope
* Find UART
  * Use FCC ID to find high-res photos to find pinouts, etc.
  * *Find Ground First*
    * Multimeter with sounds help
  * TX/RX swapped
* DVRF (Damn Vulnerable Router Firmware) project
  * Inspired by DVL, DVWA
  * MIPS 32 LE
  * E1550 router based
  * https://github.com/praetorian-inc/DVRF
