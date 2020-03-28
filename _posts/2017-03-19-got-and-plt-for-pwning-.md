---
layout: post
title: "GOT and PLT for pwning."
category: Security
date: 2017-03-19
tags:
  - Pwning
  - Linux
---

So, during the recent 0CTF, one of my teammates was asking me about RELRO and
the GOT and the PLT and all of the ELF sections involved.  I realized that
though I knew the general concepts, I didn't know as much as I should, so I did
some research to find out some more.  This is documenting the research (and
hoping it's useful for others).

<!--more-->

All of the examples below will be on an x86 Linux platform, but the concepts all
apply equally to x86-64.  (And, I assume, other architectures on Linux, as the
concepts are related to ELF linking and glibc, but I haven't checked.)

### High-Level Introduction ###

So what is all of this nonsense about?  Well, there's two types of binaries on
any system: **statically linked** and **dynamically linked**.  Statically linked
binaries are self-contained, containing all of the code necessary for them to
run within the single file, and do not depend on any external libraries.
Dynamically linked binaries (which are the default when you run `gcc` and most
other compilers) do not include a lot of functions, but rely on system libraries
to provide a portion of the functionality.  For example, when your binary uses
`printf` to print some data, the actual implementation of `printf` is part of
the system C library.  Typically, on current GNU/Linux systems, this is provided
by `libc.so.6`, which is the name of the current GNU Libc library.

In order to locate these functions, your program needs to know the address of
`printf` to call it.  While this could be written into the raw binary at compile
time, there's some problems with that strategy:

1. Each time the library changes, the addresses of the functions within the
   library change, when libc is upgraded, you'd need to rebuild *every* binary
   on your system.  While this might appeal to Gentoo users, the rest of us
   would find it an upgrade challenge to replace every binary every time libc
   received an update.
2. Modern systems using ASLR load libraries at different locations on each
   program invocation.  Hardcoding addresses would render this impossible.

Consequently, a strategy was developed to allow looking up all of these
addresses when the program was run and providing a mechanism to call these
functions from libraries.  This is known as **relocation**, and the hard work of
doing this at runtime is performed by the linker, aka `ld-linux.so`.  (Note that
*every* dynamically linked program will be linked against the linker, this is
actually set in a special ELF section called `.interp`.)  The linker is actually
run *before* any code from your program or libc, but this is completely
abstracted from the user by the Linux kernel.

### Relocations ###

Looking at an ELF file, you will discover that it has a number of sections, and
it turns out that relocations require *several* of these sections.  I'll start
by defining the sections, then discuss how they're used in practice.

.got
:  This is the GOT, or Global Offset Table.  This is the actual table of offsets
   as filled in by the linker for external symbols.

.plt
:  This is the PLT, or Procedure Linkage Table.  These are stubs that look up
   the addresses in the `.got.plt` section, and either jump to the right address,
   or trigger the code in the linker to look up the address.  (If the address
   has not been filled in to `.got.plt` yet.)

.got.plt
:  This is the GOT for the PLT.  It contains the target addresses (after they
   have been looked up) or an address back in the `.plt` to trigger the lookup.
   Classically, this data was part of the `.got` section.

.plt.got
:  It seems like they wanted every combination of PLT and GOT!  This just seems
   to contain code to jump to the first entry of the .got.  I'm not actually
   sure what uses this.  (If you know, please reach out and let me know!  In
   testing a couple of programs, this code is not hit, but maybe there's some
   obscure case for this.)

TL;DR: Those starting with `.plt` contain stubs to jump to the target, those
starting with `.got` are tables of the target addresses.

Let's walk through the way a relocation is used in a typical binary.  We'll
include two libc functions: `puts` and `exit` and show the state of the
various sections as we go along.

Here's our source:

```c
// Build with: gcc -m32 -no-pie -g -o plt plt.c

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
  puts("Hello world!");
  exit(0);
}
```

Let's examine the section headers:

```
There are 36 section headers, starting at offset 0x1fb4:

Section Headers:
  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
  [12] .plt              PROGBITS        080482f0 0002f0 000040 04  AX  0   0 16
  [13] .plt.got          PROGBITS        08048330 000330 000008 00  AX  0   0  8
  [14] .text             PROGBITS        08048340 000340 0001a2 00  AX  0   0 16
  [23] .got              PROGBITS        08049ffc 000ffc 000004 04  WA  0   0  4
  [24] .got.plt          PROGBITS        0804a000 001000 000018 04  WA  0   0  4
```

I've left only the sections I'll be talking about, the full program is 36
sections!

So let's walk through this process with the use of GDB.  (I'm using the
fantastic GDB environment provided by [pwndbg](https://github.com/pwndbg/pwndbg),
so some UI elements might look a bit different from vanilla GDB.) We'll load up our
binary and set a breakpoint just before `puts` gets called and then examine
the flow step-by-step:

```
pwndbg> disass main
Dump of assembler code for function main:
   0x0804843b <+0>:	lea    ecx,[esp+0x4]
   0x0804843f <+4>:	and    esp,0xfffffff0
   0x08048442 <+7>:	push   DWORD PTR [ecx-0x4]
   0x08048445 <+10>:	push   ebp
   0x08048446 <+11>:	mov    ebp,esp
   0x08048448 <+13>:	push   ebx
   0x08048449 <+14>:	push   ecx
   0x0804844a <+15>:	call   0x8048370 <__x86.get_pc_thunk.bx>
   0x0804844f <+20>:	add    ebx,0x1bb1
   0x08048455 <+26>:	sub    esp,0xc
   0x08048458 <+29>:	lea    eax,[ebx-0x1b00]
   0x0804845e <+35>:	push   eax
   0x0804845f <+36>:	call   0x8048300 <puts@plt>
   0x08048464 <+41>:	add    esp,0x10
   0x08048467 <+44>:	sub    esp,0xc
   0x0804846a <+47>:	push   0x0
   0x0804846c <+49>:	call   0x8048310 <exit@plt>
End of assembler dump.
pwndbg> break *0x0804845f
Breakpoint 1 at 0x804845f: file plt.c, line 7.
pwndbg> r
Breakpoint *0x0804845f
pwndbg> x/i $pc
=> 0x804845f <main+36>:	call   0x8048300 <puts@plt>
```

Ok, we're about to call puts.  Note that the address being called is local to
our binary, in the `.plt` section, hence the special symbol name of `puts@plt`.
Let's step through the process until we get to the actual `puts` function.

```
pwndbg> si
pwndbg> x/i $pc
=> 0x8048300 <puts@plt>:	jmp    DWORD PTR ds:0x804a00c
```

We're in the PLT, and we see that we're performing a jmp, but this is not a
typical jmp.  This is what a jmp to a function pointer would look like.  The
processor will dereference the pointer, then jump to resulting address.

Let's check the dereference and follow the jmp.  Note that the pointer is in
the `.got.plt` section as we described above.

```
pwndbg> x/wx 0x804a00c
0x804a00c:	0x08048306
pwndbg> si
0x08048306 in puts@plt ()
pwndbg> x/2i $pc
=> 0x8048306 <puts@plt+6>:	push   0x0
   0x804830b <puts@plt+11>:	jmp    0x80482f0
```

Well, that's weird.  We've just jumped to the next instruction!  Why has this
occurred?  Well, it turns out that because we haven't called `puts` before,
we need to trigger the first lookup.  It pushes the slot number (0x0) on the
stack, then calls the routine to lookup the symbol name.  This happens to be
the beginning of the `.plt` section.  What does this stub do?  Let's find out.

```
pwndbg> si
pwndbg> si
pwndbg> x/2i $pc
=> 0x80482f0: push   DWORD PTR ds:0x804a004
   0x80482f6: jmp    DWORD PTR ds:0x804a008
```

Now, we push the value of the second entry in `.got.plt`, then jump to the
address stored in the third entry.  Let's examine those values and carry on.

```
pwndbg> x/2wx 0x804a004
0x804a004:  0xf7ffd918  0xf7fedf40
```

Wait, where is that pointing?  It turns out the first one points into the data
segment of `ld.so`, and the 2nd into the executable area:

```
0xf7fd9000 0xf7ffb000 r-xp    22000 0      /lib/i386-linux-gnu/ld-2.24.so
0xf7ffc000 0xf7ffd000 r--p     1000 22000  /lib/i386-linux-gnu/ld-2.24.so
0xf7ffd000 0xf7ffe000 rw-p     1000 23000  /lib/i386-linux-gnu/ld-2.24.so
```

Ah, finally, we're asking for the information for the `puts` symbol!  These two
addresses in the `.got.plt` section are populated by the linker/loader
(`ld.so`) at the time it is loading the binary.

So, I'm going to treat what happens in `ld.so` as a black box.  I encourage you
to look into it, but exactly *how* it looks up the symbols is a little bit *too*
low level for this post.  Suffice it to say that eventually we will reach a ret
from the ld.so code that resolves the symbol.

```
pwndbg> x/i $pc
=> 0xf7fedf5b:  ret    0xc
pwndbg> ni
pwndbg> info symbol $pc
puts in section .text of /lib/i386-linux-gnu/libc.so.6
```

Look at that, we find ourselves at `puts`, exactly where we'd like to be.
Let's see how our stack looks at this point:

```
pwndbg> x/4wx $esp
0xffffcc2c: 0x08048464  0x08048500  0xffffccf4  0xffffccfc
pwndbg> x/s *(int *)($esp+4)
0x8048500:  "Hello world!"
```

Absolutely no trace of the trip through `.plt`, `ld.so`, or anything but what
you'd expect from a direct call to puts.

Unfortunately, this seemed like a *long* trip to get from `main` to `puts`.  Do
we have to go through that every time?  Fortunately, no.  Let's look at our
entry in `.got.plt` again, disassembling `puts@plt` to verify the address first:

```
pwndbg> disass 'puts@plt'
Dump of assembler code for function puts@plt:
   0x08048300 <+0>:	jmp    DWORD PTR ds:0x804a00c
   0x08048306 <+6>:	push   0x0
   0x0804830b <+11>:	jmp    0x80482f0
End of assembler dump.
pwndbg> x/wx 0x804a00c
0x804a00c:	0xf7e4b870
pwndbg> info symbol 0xf7e4b870
puts in section .text of /lib/i386-linux-gnu/libc.so.6
```

So now, a `call puts@plt` results in a immediate `jmp` to the address of `puts`
as loaded from libc.  At this point, the overhead of the relocation is one extra
jmp.  (Ok, and dereferencing the pointer which might cause a cache load, but I
suspect the GOT is very often in L1 or at least L2, so very little overhead.)

How did the `.got.plt` get updated?  That's why a pointer to the beginning of
the GOT was passed as an argument back to `ld.so`.  `ld.so` did magic and
inserted the proper address in the GOT to replace the previous address which
pointed to the next instruction in the PLT.

### Pwning Relocations ###

Alright, well now that we think we know how this all works, how can I, as a
pwner, make use of this?  Well, pwning usually involves taking control of the
flow of execution of a program.  Let's look at the permissions of the sections
we've been dealing with:

```
Section Headers:
  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
  [12] .plt              PROGBITS        080482f0 0002f0 000040 04  AX  0   0 16
  [13] .plt.got          PROGBITS        08048330 000330 000008 00  AX  0   0  8
  [14] .text             PROGBITS        08048340 000340 0001a2 00  AX  0   0 16
  [23] .got              PROGBITS        08049ffc 000ffc 000004 04  WA  0   0  4
  [24] .got.plt          PROGBITS        0804a000 001000 000018 04  WA  0   0  4

Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
```

We'll note that, as is typical for a system supporting NX, no section has both
the Write and eXecute flags enabled.  So we won't be overwriting any executable
sections, but we should be used to that.

On the other hand, the `.got.plt` section is basically a giant array of function
pointers!  Maybe we could overwrite one of these and control execution from
there.  It turns out this is quite a common technique, as described in a [2001
paper from team teso](https://cs155.stanford.edu/papers/formatstring-1.2.pdf).
(Hey, I never said the technique was new.)  Essentially, any memory corruption
primitive that will let you write to an arbitrary (attacker-controlled) address
will allow you to overwrite a GOT entry.

### Mitigations ###

So, since this exploit technique has been known for so long, surely someone has
done something about it, right?  Well, it turns out yes, there's been a
[mitigation since 2004](https://www.sourceware.org/ml/binutils/2004-01/msg00070.html).
Enter relocations read-only, or **RELRO**.  It in fact has two levels of
protection: partial and full RELRO.

Partial RELRO (enabled with `-Wl,-z,relro`):

* Maps the `.got` section as read-only (but *not* `.got.plt`)
* Rearranges sections to reduce the likelihood of global variables overflowing
  into control structures.

Full RELRO (enabled with `-Wl,-z,relro,-z,now`):

* Does the steps of Partial RELRO, plus:
* Causes the linker to resolve all symbols at link time (before starting
  execution) and then remove write permissions from `.got`.
* `.got.plt` is merged into `.got` with full RELRO, so you won't see this
  section name.

Only full RELRO protects against overwriting function pointers in `.got.plt`.
It works by causing the linker to immediately look up every symbol in the PLT
and update the addresses, then `mprotect` the page to no longer be writable.

### Summary ###

The `.got.plt` is an attractive target for `printf` format string exploitation
and other arbitrary write exploits, especially when your target binary lacks
PIE, causing the `.got.plt` to be loaded at a fixed address.  Enabling Full
RELRO protects against these attacks by preventing writing to the GOT.

### References ###

- [ELF Format Reference](http://www.skyfree.org/linux/references/ELF_Format.pdf)
- [Examining Dynamic Linking with GDB](http://www.cs.dartmouth.edu/~sergey/cs108/dyn-linking-with-gdb.txt)
- [RELRO - A (not so well known) Memory Corruption Mitigation Technique](https://tk-blog.blogspot.com/2009/02/relro-not-so-well-known-memory.html)
- [What is the symbol and the global offset table?](https://www.codeproject.com/articles/1032231/what-is-the-symbol-table-and-what-is-the-global-of)
- [How the ELF ruined Christmas](https://www.usenix.org/system/files/conference/usenixsecurity15/sec15-paper-di-frederico.pdf)
