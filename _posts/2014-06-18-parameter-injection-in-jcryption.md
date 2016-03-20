---
layout: post
title: "Parameter Injection in jCryption"
date: 2014-06-18 01:00:00 +0000
permalink: /2014/06/18/parameter-injection-in-jcryption/
category: Security
tags: Vulnerability Research,Security,Cryptography
---
jCryption is an open-source plugin for jQuery that is used for performing encryption on the client side that can be decrypted server side.  It works by retrieving an RSA key from the server, then encrypting an AES key under the RSA key, and sending both the encrypted AES key and the RSA key to the server.  This is not dissimilar to how OpenPGP encrypts data for transmission.  (Though, of course, implementation details are vastly different.)

jCryption comes with PHP and perl code demonstrating the decryption server-side, and while not packaged as ready-to-use libraries, it is likely that most users used the sample code for the server-side implementation.  While the code used proc_open, which doesn't allow command injection (it's not being run through a shell, so shell metacharacters aren't relevant) still allows an attacker to modify the arguments being passed to the command.

Originally, the code used constructs like:

    #!php
    $cmd = sprintf("openssl enc -aes-256-cbc -pass pass:'$key' -a -e");

Because `$key` can be attacker-controlled, an attacker can close the pass string early, and add additional openssl parameters there.  This includes, for example, the ability to read the jCryption RSA private key, allowing an attacker to read any traffic sent with jCryption that they have captured (or capture in the future).

I reported this issue late last night, and Daniel Griesser, the author of jCryption, replied shortly thereafter, confirming he was looking into the matter.  By this morning, he had created a fix and pushed a new release out.  It speaks very highly of a developer when they're able to respond so quickly to a security concern.

For the curious, it was fixed by escaping the shell argument using `escapeshellarg`:

    #!php
    $cmd = sprintf("openssl enc -aes-256-cbc -pass pass:" . escapeshellarg($key) . " -a -e");

I'm not releasing a PoC that does the actual crypto steps at this point, I want to make sure sites have had a chance to upgrade.
