---
layout: post
title: "Ghost in the Shellcode 2014: Pillowtalk"
date: 2014-01-19 19:11:27 +0000
permalink: /2014/01/19/ghost-in-the-shellcode-2014-pillowtalk/
category: Security
tags:
  - CTF
  - Ghost in the Shellcode
  - Security
  - Shadow Cats
redirect_from:
  - /blog/ghost-in-the-shellcode-2014-pillowtalk/
---
Pillowtalk was a 200 point crypto challenge.  Provided was a stripped 64-bit binary along with a pcap file.  I started off by exercising the behavior of the binary, looking at system calls/library calls to see what it was doing.

 - Client connects to server
 - Server reads 32 bytes from /dev/urandom
 - Server sends 32 bytes on the wire (not same bytes as read from /dev/urandom)
 - Client does same 32 byte read/send
 - Loop:
     - Server reads a line from stdin
     - Server sends 4 byte length
     - Server sends encrypted line
     - Client does the same steps

My first approach was by trying to use scapy to replay the pcap to the server, but this only gave complete noise, so I decided the two 32 byte values must be significant.  I even tried controlling /dev/urandom (via LD_PRELOAD) to see if putting in the 32 bytes from the pcap would get to the right key.  It didn't.

I started reversing the binary and the behavior of the translation of the 32 bytes from /dev/urandom to the 32 bytes put on the wire.  Eventually I came to the conclusion (later confirmed) that the 32 bytes from /dev/urandom were used as a private key to Curve25519, leading to the 32 bytes on the wire as a public key.  The 2 values would then be used by each end for key agreement for the symmetric cipher.  Breaking Curve25519 seemd a bit out of scope for a CTF, so I assumed it was an implementation problem with the symmetric crypto.

It was worth noting that the ciphertext was the exact same length as the plaintext, implying that a stream cipher was in use, and that if the same plaintext was sent twice, it encrypted the same way, implying that the cipher was being reset before sending each message.  This leaves messages vulnerable to known-plaintext attacks by revealing the keystream.

I started by xoring the last byte of each message with '\n', and recording the position/value pairs, then xoring each byte at those positions in each message with our newly revealed keystream bytes.  I also ventured a guess that the first message was 'hi\n', so repeated the same process for the first 2 bytes.  This gave me enough revealed plaintext to start making guesses about other bytes, and repeating this process with each set of bytes revealed the flag.
