---
layout: post
title: "ASIS CTF 2016: firtog"
category: Security
date: 2016-05-08
tags:
  - Security
  - CTF
---

Firtog gives us a pcap file that you can quickly see features several TCP
sessions containing the git server protocol.  The binary protocol looks like
this in the follow TCP stream mode:

![firtog wireshark](/img/blog/asis-2016/firtog_wireshark.png)

Switching Wireshark to decode this as "Git" *almost* works, but there's a trick.
If we read the [git pack
protocol](https://github.com/git/git/blob/master/Documentation/technical/pack-protocol.txt)
documentation, we'll see there's a special side-band mode here, where the length
field is followed with a '1', '2', or '3' byte indicating the type of data to
follow.  We only want the data from sideband '1', which is the actual packfile
data.  So we'll grab that data using Wireshark and write it to a file, fixing up
the last byte with quick python work.

Once we have the packfiles, we recreate the git repository.  Begin by creating
an empty git repository with `git init`.  Then, we can use `git unpack-objects <
PACKFILE` on each of the packfiles (in order, or else we won't get the deltas
resolved properly).  Finally, to get the structure back to normal, run `git
fsck` and you'll see something like this:

~~~
% git fsck
Checking object directories: 100% (256/256), done.
Checking objects: 100% (21/21), done.
dangling commit 922faaf7d9a6f74eb661acc62b93b968ec3f781f
~~~

This dangling commit tells us it's the only unreferenced commit in the
repository (i.e., not referenced as a parent by a commit or merge), so let's
check that one out:

~~~
% git checkout 922fa
HEAD is now at 922faaf... a new encrypted flag :P:P
~~~

Ok, so now we're somewhere.  Let's see what we have:

~~~
% ls
flag.py  flag.txt  readme
% cat flag.py
#!/usr/bin/python
# Simple but secure flag generator for ASIS CTF Quals 2016

from os import urandom
from hashlib import sha1

l = 128
rd = urandom(l)
h = sha1(rd).hexdigest()
flag = 'ASIS{' + h + '}'
print flag
f = open('flag.txt', 'w')
flag_enc = ''
for c in flag:
  flag_enc += hex(pow(ord(c), 65537, 143))[2:]
f.write(flag_enc)
f.close()
% cat flag.txt
41608a606a63201245f1020d205f1612147463d85d125c1416635c854c74d172010105c14f8555d125c3c
~~~

So they grabbed some random data and hashed it, then did some exponentiation
byte-by-byte to produce the output.  There's probably some better way to reverse
it, but since it's a limited character set, I just created a map of values to
reverse the flag by performing the same math they did.

~~~
% cat flagdec.py 
flag = '41608a606a63201245f1020d205f1612147463d85d125c1416635c854c74d172010105c14f8555d125c3c'

lookup = {}

for b in 'ASIS{}0123456789abcdef':
    lookup[hex(pow(ord(b), 65537, 143))[2:]] = b

i = 0
out = ''
while i < len(flag):
    try:
        out += lookup[flag[i]]
    except KeyError:
        out += lookup[flag[i] + flag[i+1]]
        i += 1
    i += 1

print out
% python flagdec.py 
ASIS{c691a0646e79f3c4d495f7c5db3486005fad2495}
~~~

(I apologize for the quality of the code, but hey, it's CTF-quality, not
production-quality.)
