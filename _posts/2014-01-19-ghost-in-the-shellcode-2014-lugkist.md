---
layout: post
title: "Ghost in the Shellcode 2014: Lugkist"
date: 2014-01-19 19:43:56 +0000
permalink: /2014/01/19/ghost-in-the-shellcode-2014-lugkist/
category: Security
tags: CTF,Ghost in the Shellcode,Shadow Cats,Security
---
Lugkist was an interesting "trivia" challenge.  We were told "it's not crypto", but it sure looked like a crypto challenge.  We had a file like:

> Find the key.
>
> GVZSNG  
> AXZIOG  
> YNAISG  
> ASAIUG  
> IVPIOK  
> AXPIVG  
> PVZIUG  
> AXLIEG

Always 6 letters, but no other obvious pattern.  I did notice that the 4th character always was S or I and the final character G or K, but couldn't make anything of that. I realized the full character set was 'AEGIKLONPSUTVYXZ'.  Searching for this string revealed nothing, but searching for the characters space separated revealed that this was the same character set as used by the codes for the original Game Genie.  And Game Genie codes were 6 characters long.

So, they're Game Genie codes.  What now?  Well, there's a handy (NES Game Genie Technical Notes)[http://tuxnes.sourceforge.net/gamegenie.html] that tells us how the characters decode.  Turns out the characters are an alphabetical hexadecimal (there are 16 of them) but not in alphabetical order.  Decoding the resulting hex was useless.  The technical notes also tell us how to decode the address and data from the codes.  Giving that a try doesn't reveal anything obvious, but it was noteworthy that the data values were all within the normal printable ASCII range.  The addresses seemed randomly ordered, but were contiguous.  Maybe sorting by address and taking the values as characters to build a string?

"Power overwhelming? Back in my day cheats did not have spaces."

Full translation code (in python) is below.

    #!python
    codes = 'APZLGITYEOXUKSVN'
    xlate = {c: i for i,c in enumerate(codes)}
    
    def numeric(s):
      return [xlate[x] for x in s]
    
    def address(s):
      n = numeric(s)
      return (0x8000 +
          ((n[3] & 7) << 12) |
          ((n[5] & 7) << 8) |
          ((n[4] & 8) << 8) |
          ((n[2] & 7) << 4) |
          ((n[1] & 8) << 4) |
          (n[4] & 7) |
          (n[3] & 8))
    
    def data(s):
      n = numeric(s)
      return (((n[1] & 7) << 4) |
              ((n[0] & 8) << 4) |
              (n[0] & 7) |
              (n[5] & 8))
    
    prev_addr = 0
    addrs = []
    addr_dict = {}
    with open('lugkist.2') as f:
      for l in f:
        l = l.strip()
        a = address(l)
        #print 'A: %04x [%04x]' % (a, a-prev_addr)
        prev_addr = a
        addrs.append(a)
        addr_dict[a] = l
    
    chars = []
    for x in sorted(addrs):
      chars.append(chr(data(addr_dict[x])))
    
    print ''.join(chars)


