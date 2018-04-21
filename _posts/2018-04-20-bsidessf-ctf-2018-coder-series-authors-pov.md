---
layout: post
title: "BSidesSF CTF 2018: Coder Series (Author's PoV)"
category: Security
date: 2018-04-20
tags:
  - CTFs
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

### Solving the Challenges ###
