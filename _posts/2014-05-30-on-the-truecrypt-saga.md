---
layout: post
title: "On the TrueCrypt Saga"
date: 2014-05-30 00:52:47 +0000
permalink: /blog/on-the-truecrypt-saga/
categories: Freedom,Security
tags: Cryptography,Security
---
If you're anywhere near the security community, you've probably already heard about the (supposed) [end of TrueCrypt](http://truecrypt.sourceforge.net/) that inspired a [massive hunt for an explanation on Reddit](http://www.reddit.com/r/netsec/comments/26pz9b/truecrypt_development_has_ended_052814/).  I'm going to drop my thoughts here, but these are all just speculation, so take them for what they're worth (which is not much).

#### The Facts as We Know Them
1. **TrueCrypt 7.2 dropped support for creating volumes.** The code was massively changed, stripping out all volume creation options.
2. **The website was updated with terrible instructions.** The directions for alternatives generally point to proprietary options (BitLocker, File Vault, or, to paraphrase, "whatever you can find on Linux.")
3. **The new version is signed with the same key** as previous versions.  This implies whoever did the update is in possession of the key used for signing previous releases.
4. **Sourceforge doesn't think the account was compromised** as posted [here](https://news.ycombinator.com/item?id=7813121).

####Popular Theories
1. **The author was forced to backdoor TC and chose this instead.**  This seems to be the most popular theory, and given the Snowden revelations, it's easy to see why.  Assuming the adversary in question is the US Government, this seems awfully heavy-handed, and I'm not sure under which legal authority they would attempt to compel this participation.  NSLs compel the production of business records, but don't seem to allow them to force a backdooring.  CALEA is for communications tools, TrueCrypt is used for storage at rest.  Even those who refer to LavaBit are referring to warrants.  First LavaBit was ordered to turn over messages, then encryption keys, but I'm not aware they were ever ordered to backdoor their software.  It also seems odd that government agencies would choose to go after disk encryption, seems like communications encryption would be the bigger source of intelligence.  There are those who have claimed "the government can force you to do anything", which I suppose is true, but if we're at the stage of "backdoor your code or we treat you as a terrorist" then the game's already over, we're off in [Stasi](https://en.wikipedia.org/wiki/Stasi) territory, and I'm not sure that's a world I could live in.  I **hope** this is not the story.
2. **The author tired of developing it** and just gave up.  This is a kind of odd approach, one would think they'd look for someone to hand the project to.  I'm also not sure why someone who'd devoted years to developing secure encryption software would suddenly offer up terrible alternatives or otherwise deviate so strangely.
3. **A developer was compromised.**  While this might give access to the PGP key, I'd have thought by now we'd have some sort of communication somewhere to claim this has happened.  Unless the developer is completely out of the loop as well.  Why would someone use the compromise to offer up terrible alternatives as opposed to releasing backdoored binaries quietly?
4. **Off their meds.**  A couple of people have suggested that some sort of psychiatric problem is involved here.  Actually seems a little reasonable, given the erratically written directions for alternatives, the sudden change in course, everything.  Of course, there's no evidence to support this, so it's really just speculation.

*I've turned off commenting as I think Reddit or Hacker News is a better place for such discussion, I just had a lot of thoughts I wanted to get out.*
