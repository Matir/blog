---
layout: post
title: "Security 101: Backups & Protecting Backups"
category: Security
tags:
  - Security 101
description:
  Backups and protecting your backups are key to a reasonable security posture.
date: 2020-07-26
---

I can already hear some readers saying that backups are an IT problem, and not a
security problem.  The reality, of course, is that they're both.  Information
security is commonly thought of in terms of the
[CIA Triad](https://en.wikipedia.org/wiki/Information_security#Key_concepts) --
that is, Confidentiality, Integrity, and Availability, and it's important to
remember those concepts when dealing with backups.

We need look no farther than the troubles [Garmin is
having](https://techcrunch.com/2020/07/25/garmin-outage-ransomware-sources/) in
dealing with a ransomware attack to find evidence that backups are critical.
It's unclear whether Garmin lacked adequate backups, had their backups
ransomware'd, or is struggling to restore from backups.  (It's possible that
they never considered an issue of this scale and simply aren't resourced to
restore this quickly, but given that the outage remains a complete outage after
4 days, I'd bet on one of those 3 conditions.)

<!--more-->

So what does a security professional need to know about backups?  Every
organization is different, so I'm not going to try to provide a formula or
tutorial for how to do backups, but rather discuss the security concepts in
dealing with backups.

Before I got into security, I was both a Site Reliability Engineer (SRE) and a
Systems Administrator, so I've had my opportunities to think about backups from
a number of different directions.  I'll try to incorporate both sides of that
here.

## Availability ##

I want to deal with **availability** first, because that's really what backups
are for.  Backups are your last line of defense in ensuring the availability of
data and services.  In theory, when the service is down, you should be able to
restore from backups and get going (with the possibility of some data loss in
between the time of the backup and the restoration).

### Availability Threat: Disaster ###

Anyone who's had to deal with backups has probably given some thoughts to the
various disasters that can strike their primary operations.  There are numerous
disasters that can take out an entire datacenter, including fire, earthquake,
tornadoes, flooding, and more.  Just as a general rule, assume a datacenter will
disappear, so you need a full copy of your data somewhere else as well as the
ability to restore operations from that location.

This also means you can't rely on *anything* in that datacenter for your
restoration.  We'll talk about encryption under confidentiality, but suffice it
to say that you need your backup configs, metadata (what backup is stored
where), encryption keys, and more in a way you can access them if you lose that
site.  A lot of this would be great to store completely offline, such as in a
safe in your office (assuming it's sufficiently far from the datacenter to be
unaffected).

### Availability Threat: Malware ###

While replicating your data across two sites would likely protect against
natural disasters, it won't be enough to protect against malware.  Whether
ransomware or malware that just wants to destroy your data, network connectivity
would place both sets of data at risk if you don't take precautions.

One option is using backup software that provides versioning controlled by the
provider.  For small business or SOHO use, providers like
[BackBlaze](https://help.backblaze.com/hc/en-us/articles/360035247494-Version-History-FAQ)
and [SpiderOak](https://spideroak.com/one/) offer this.  Another choice is using
a cloud provider for storage and enabling a provider-enforced policy like
[Retention Policies on GCP](https://cloud.google.com/storage/docs/bucket-lock).

Alternatively, using a "pull" backup configuration (where backups are "pulled"
from the system by a backup system) can help with this as well.  By having the
backup system pull, malware on the serving system cannot access anything but the
currently online data.  You still need to ensure you retain older versions to
avoid just backing up the ransomware'd data.

At the end of the day, what you want is to ensure that an infected system cannot
*delete*, *modify*, or *replace* its own backups.  Remember that anything a
legitimate user or service on the machine can do can also be done by malware.

Another consideration is how the backup service is administered.  If, for
example, your backups are stored on servers joined to your Windows domain and a
domain administrator or domain controller is compromised, then the malware can
also hop to the backup server and encrypt/destroy the backups.  If your backups
are exposed as a writable share to any compromised machine, then, again, the
malware can have it's way with your backups.

Of course, offline backups can mitigate most of the risks as well.  Placing
backups onto tapes or hard drives that are physically disconnected is a great
way to avoid exposing those backups to malware, but it also adds significant
complexity to your backup scheme.

### Availability Threat: Insider ###

You may also want to consider a malicious insider when designing your backup
strategy.  While many of the steps that protect against malware will help
against an insider, considering who has access to your backup strategy and what
unilateral access they have is important.

Using a 3rd party service with an enforced retention period can help, as can
layers of backups administered by different individuals.  Offline backups also
make it harder for an individual to quickly destroy data.

Ensuring that the backup administrator is also not in a good position to destroy
your live data can also help protect against their ability to have too much
impact on your organization.

## Confidentiality ##

It's critical to protect your data.  Since many backup approaches involve
entrusting your data to a 3rd party (whether it's a cloud provider, an archival
storage company, or a colocated data center), encryption is commonly employed to
ensure **confidentiality** of the data stored.  (Naturally, the key should not
be stored with the 3rd party.)

Fun anecdote: at a previous employer, we had our backup tapes stored offsite by
a 3rd party backup provider.  The tapes were picked up and delivered in a locked
box, and we were told that only we possessed the key to the box.  I became
"suspicious" when we added a new person to our authorized list (those who are
allowed to request backups back from the vendor) and the person's ID card was
delivered inside our locked box.  (Needless to say, you can't trust statements
like that from a vendor -- not to mention that a plastic box is not a security
boundary.)

All the data you backup should be encrypted with a key your organization
controls, and you should have access to that key even if your network is
completely trashed.  I recommend storing it in a safe, preferrably on a
smartcard or other secure element.  (Ideally in a couple of locations to hedge
your bets.)

A fun bit about encrypted backups: if you use proper encryption, destroying the
key is equivalent to destroying all the backups encrypted with that key.  Some
organizations do this as a way of expiring old data.  You can have the data
spread across all kinds of tapes, but once the key is destroyed, you will never
be recovering that data.  (On the other hand, if a malicious actor destroys your
key, you will also never be recovering that data.)

## Integrity ##

Your backups need to be **integrity protected** -- that is, protected against
tampering or modification.  This both protects against accidental modifications
(i.e., corruption from bad media, physical damage, etc.) as well as tampering.
While encryption makes it harder for an adversary to modify data in a controlled
fashion, it is still possible.  (This is a property of encryption known as
[Malleability](https://en.wikipedia.org/wiki/Malleability_(cryptography)).)

Ideally, backups should be cryptographyically signed.  This prevents both
accidental and malicious modification to the underlying data.  A common approach
is to build a manifest of cryptographic hashes (i.e., SHA-256) of each file and
then sign that.  The individual hashes can be computed in parallel and even on
multiple hosts, then the finished manifest can be signed.  (Possibly on a
different host.)

These hashes can also be used to verify the backups as written to ensure against
damage during the writing of backups.  Only the signing machines need access to
the private key (which should ideally be stored in a hardware-backed key storage
mechanism like a smart card or TPM).

## Backup Strategy Testing ##

No matter what strategy you end up designing (which should be a joint function
between the core IT group and the security team), the strategy needs to be
evaluated and tested.  Restoration needs to be tested, and threats need to be
considered.

### Practicing Restoration ###

This is likely to be far more a function of IT/production teams than of the
security team, but you have to test restoration.  I've seen too many backup
plans without a tested restoration plan that wouldn't work in practice.

Fails I've seen or heard of:

- Relying on encryption to protect the backup, but then not having a copy of
  the encryption key at the time of restoration.
- Using tapes for backups, but not having metadata of what was backed up on what
  tape.  (Tapes are *slow*, imagine searching for the data you need.)

### Tabletop Scenarios ###

When designing a backup strategy, I suggest doing a series of tabletop
exercises to evaluate risks.  Having a subset of the team play "red team" and
attempt to destroy the data or access confidential data or apply ransomware to
the network and the rest of the team evaluating controls to prevent this is a
great way to discover gaps in your thought process.

Likewise, explicitly threat modeling ransomware into your backup strategy is
critical, as we've seen increased use of this tactic by cybercriminals.  Even
though defenses to prevent ransomware getting on your network in the first place
would be ideal, real security involves defense in depth, and having workable
backups is a key mitigation for the risks posed by ransomware.
