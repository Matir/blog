---
layout: post
title: "(Tiny) Tool Release: Pwnpattern"
date: 2016-03-16
category: Security
---

Just a quick note to go with something I dropped on Github recently:
[pwnpattern](https://github.com/Matir/pwnpattern) is a python library and
stand-alone script that replicates most of the functionality of Metasploit
Framework's `pattern_create.rb` and `pattern_offset.rb`.  The patterns created
are identical to those from Metasploit, so you can even mix and match tools.

There are several reasons I wrote this:

* You don't need a full copy of metasploit installed for creating patterns for e.g.,
  wargames, CTFs, etc.
* It loads much more quickly: on my machine, Metasploit's `pattern_create.rb` takes
  2.29s, my script takes 0.01s.  This is due, of course, to dependencies (MSF's
  requires the entire Rex library to be loaded) but it is kind of nice to not
  wait for things.
* It can be embedded in python scripts (just like Rex can be embedded in Ruby
  scripts).
