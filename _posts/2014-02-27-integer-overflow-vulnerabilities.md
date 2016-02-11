---
layout: post
title: "Integer Overflow Vulnerabilities"
date: 2014-02-27 04:01:07 +0000
permalink: /blog/integer-overflow-vulnerabilities/
category: Security
tags: Security,Exploitation
---
What's wrong with this code (other than the fact the messages are discarded)?

    #!c
    void read_messages(int fd, int num_msgs) {
      char buf[1024];
      size_t msg_len, bytes_read = 0;
    
      while(num_msgs--) {
        read(fd, &msg_len, sizeof(size_t));
        if (bytes_read + msg_len > sizeof(buf)) {
          printf("Buffer overflow prevented!\n");
          return;
        }
        bytes_read += read(fd, buf+bytes_read, msg_len);
      }
    }

If you answered "nothing", you'd be missing a significant security issue.  In fact, this function contains a trivial buffer overflow.  By supplying a length <code>0 &lt; len_a &lt; 1024</code> for the first message, then a length <code> INT_MAX-len_a &le; len_b &lt; UINT_MAX</code>, the value <code>bytes_read + msg_len</code> wraps around past <code>UINT_MAX</code> and is less than <code>sizeof(buf)</code>.  Then the read proceeds with its very large value, but can only read as much data as is available on the file descriptor (probably a socket, if this is a remote exploit).  So by supplying enough data on the socket, the buffer will be overflowed, allowing to overwrite the saved EIP.

One way to fix this vulnerability is to move the bytes_read on the other side of the comparison.

    #!c
    void read_messages(int fd, int num_msgs) {
      char buf[1024];
      size_t msg_len, bytes_read = 0;
    
      while(num_msgs--) {
        read(fd, &msg_len, sizeof(size_t));
        if (msg_len > sizeof(buf) - bytes_read) {
          printf("Buffer overflow prevented!\n");
          return;
        }
        bytes_read += read(fd, buf+bytes_read, msg_len);
      }
    }

Since <code>0 &le; bytes_read &le; sizeof(buf)</code> the right side will not underflow, and msg_len will obviously always be within the range of a <code>size_t</code>.  In this case, we should not be vulnerable to a buffer overflow.

####Other Reading

  - [OWASP: Integer Overflow](https://www.owasp.org/index.php/Integer_overflow)
  - [Basic Integer Overflows (Phrack)](http://www.phrack.com/issues.html?issue=60&id=10)
