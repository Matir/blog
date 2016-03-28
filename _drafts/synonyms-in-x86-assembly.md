---
layout: post
title: Synonyms in x86 Assembly
category: Security
tags:
  - Security
  - x86
  - Assembly
---

I recently had an opportunity to [handcraft shellcode with unusual
restrictions](https://www.offensive-security.com/information-security-training/cracking-the-perimeter/),
and appreciated that there's a number of ways to accomplish any goal in an ISA
as flexible as x86.  (Most of these techniques will apply to x86-64 as well, but
the work I was doing happened to be 32 bit, so that's what I will use as an
example.)  Obviously, this won't be comprehensive, but it's just a reminder of
different ways you can do something.  If you ever think it's impossible,
remember to try harder.

Most of my examples will use `eax`, unless a special circumstance applies (i.e.,
dealing with `esp`, `eip`, etc.).  They're not all going to be strictly
synonyms, because many of them will have varying side effects (flags, etc.).  I
will try to note any that have potentially undesirable side effects like
clobbering other registers, leaving the stack modified, etc.

##### Zero Out a Register #####

~~~
mov eax, 0
~~~

Straight out zero: has the disadvantage of sticking a bunch of NULL bytes in
your output, which is a problem for many use cases.

~~~
xor eax, eax
~~~

Because `a^a=0`, xoring a register with itself clears it.  Nice and short (2
bytes) and no NULL bytes.

~~~
shl eax, 32
~~~

This works by zero-filling of shifts.

~~~
mov eax, -1
not eax
~~~

This sets `eax` to `0xFFFFFFFF`, then inverts it.

~~~
mov eax, -1
inc eax
~~~

Similarly to above, but it increments rather than inverts eax.
