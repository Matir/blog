---
layout: post
title: "DEF CON 22 CTF Quals: Hackertool"
date: 2014-05-19 03:32:11 +0000
permalink: /blog/def-con-22-ctf-quals-hackertool/
category: Security
tags: Security,CTF,DEF CON CTF,Cryptography
---
Hackertool was one of the <code>Baby's First</code> challenges in DEF CON CTF Quals this year, and provided you with a .torrent file, and asked you to download the file and MD5 it.  Seems easy enough, so I knew there must be more to it.  The torrent file itself was a whopping 4 MB in size, very large for a torrent file.  Looking at it, we see it contains just one file, named <code>every_ip_address.txt</code>, and the file is ~61GB in size.  Hrrm, there must be an easier way than torrenting 61GB, especially at <1k/s.

So what is this `every_ip_address.txt`?  Seems like it might be a list of all IP addresses.  In fact, if you add up the length of all IP addresses written in decimal dotted-quad form, separated by newlines, you get 61337501696 bytes, **exactly** the same as the length of our target torrent.  But is it newline separated?  What order are they in?  Fortunately, torrents also contain the SHA-1 of each 256kb block of the file.  So I wrote a little python script to quickly check if we had a match for the first block:

    import hashlib

    def get_block():    
      block = 256 * 1024
      v = ''
      for a in xrange(0, 256):
        for b in xrange(0, 256):
          for c in xrange(0, 256):
            for d in xrange(0, 256):
              v += '%d.%d.%d.%d\n' % (a,b,c,d)
              if len(v) > block:
                return v[:block]       


    print hashlib.sha1(get_block()).hexdigest()

This matched the value from the torrent file, so I knew we were on the right track.  Unfortunately, python is too slow to hash 61GB this way, so I turned to C for the final solution:

    #include <openssl/md5.h>
    #include <string.h>
    #include <stdio.h>
    
    int main(int argc, char **argv){
      char buf[64];
      MD5_CTX md5_ctx;
      int i,j,k,l;
    
      MD5_Init(&md5_ctx);
      for (i=0;i<256;i++) {
        printf("%d.\n", i);
        for (j=0;j<256;j++) {
          for (k=0;k<256;k++) {
            for (l=0;l<256;l++) {
              sprintf(buf, "%d.%d.%d.%d\n", i, j, k, l);
              MD5_Update(&md5_ctx, buf, strlen(buf));
            }
          }
        }
      }
      MD5_Final(buf, &md5_ctx);
      for (i=0;i<128/8;i++) {
        printf("%02ux", buf[i] & 0xFF);
      }
      printf("\n");
      return 0;
    }

There might've been prettier ways, but this ran in the background while I moved on to another hash, and got us our first flag not too long afterwards.
