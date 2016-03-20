---
layout: post
title: "LD_PRELOAD for Binary Analysis"
date: 2014-01-13 02:18:16 +0000
permalink: /2014/01/13/ld_preload-for-binary-analysis/
category: Security
tags:
  - CTF
  - Security
  - reverse engineering
  - InfoSec
  - Hacking
---
During the BreakIn CTF, there were a few challenges that depended on the return value of of libc functions like <code>time()</code> or <code>rand()</code>, and had differing behavior depending on those return values.  In order to more easily reverse those binaries, it can be nice to control the return values of those functions.  In other cases, you have binaries that may call functions like <code>unlink()</code>, <code>system()</code>, etc., where you prefer not to have those functions really called.  (Though you are running these untrusted binaries in a VM, right?)

So let's say there's a program that's built from the following source (over simplified for example):

    #!c
    #include <time.h>
    #include <stdio.h>

    int main(int argc, char **argv){
      if (time() % 86400 == 0) {
        puts("Win!\n");
        return 0;
      }
      puts("Lose\n");
      return 1;
    }

So this is obviously a highly contrived example, but you only win if you hit it exactly at midnight.  Now, I suppose you could change your computer clock, but you still only have a one second window to get it right.  How can you control this to improve your outcomes?

There's a wonderful trick that allows you to inject a custom shared library to be loaded before your program is run (and the symbols in it resolved) so that the functions provided by your library are used preferentially over the ones provided by the C library.  First, let's create our replacement version of time, and create one that allows us to set the time by setting an environment variable.  (Note that we don't have to replicate the same behavior of time(), as we know only the return value is used, and no pointer is passed in.)

    #!c
    #include <time.h>
    #include <stdlib.h>
    
    time_t time(time_t *out){
        char *tstr = getenv("TIME");
        if (tstr)
          return (time_t)atol(tstr);
        return (time_t)0;
    }

Now we can build the shared object and run the program with our version of time.  Note that you must use an absolute path for LD_PRELOAD, or it will only look in the LD search path.

    #!sh
    $ gcc -Wall -fPIC -shared -o time.so time.c
    $ TIME=0 LD_PRELOAD=`pwd`/time.so ./challenge
    Win!
    $ TIME=1 LD_PRELOAD=`pwd`/time.so ./challenge
    Lose

Note that you don't have to completely re-implement the function you want to replace, you can actually get it and call it within your replacement function.  (Note that this only works on GNU libc.)  Maybe you only want unlink to work if called with the path "/deleteme".

    #!c
    #define _GNU_SOURCE
    #include <dlfcn.h>
    #include <unistd.h>
    #include <string.h>
    #include <stdio.h>

    #define TARGET "/deleteme"

    int unlink(const char *path){
      int (*real_unlink)(const char *) = dlsym(RTLD_NEXT, "unlink");
      
      if (!strncmp(TARGET, path, strlen(TARGET))) {
        return real_unlink(path);
      }
      
      fprintf(stderr, "Would unlink(%s)", path);
      return 0;
    }

You can use the same build and preload instructions as before, and this will allow to delete "/deleteme", otherwise it will just print out what it would've done.  There are many other uses of LD_PRELOAD, but these are a couple of ways I've found useful for quick-and-dirty hacks.
