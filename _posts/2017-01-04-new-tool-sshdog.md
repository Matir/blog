---
layout: post
title: "New Tool: sshdog"
category: Security
date: 2017-01-04
tags:
  - Security
  - SSH
---

I recently needed an *encrypted*, *authenticated* remote *bind* shell due to a
situation where, believe it or not, the egress policies were stricter than
ingress!  Ideally I could forward traffic and copy files over the link.  
I was looking for a good tool and casually asked my coworkers if they had any
ideas when one said "sounds like SSH."

*Well, shit.*  That does sound like SSH and I didn't even realize it.  (Tunnel
vision, and the value of bouncing ideas off of others.)  But I had a few more
requirements in total:

- Encrypted
- Authenticated
- Bind (not reverse)
- Windows & Linux
- No Admin/Installation required
- Can be shipped preconfigured
- No special runtime requirements

At this point, I began hunting for SSH servers that fit the bill, but found
none.  So I began to think about Paramiko, the SSH library for Python, but then
I'd still need the Python runtime (though there are ways to build a binary out
of a python script).  I then recalled once seeing that Go has [an ssh
package](https://godoc.org/golang.org/x/crypto/ssh).  I looked at it, hoping it
would be as straightforward as Paramiko (which can become a full SSH server or
client in about 10 lines), but it's not quite so.  With the Go package, all of
the crypto is handled for you, but you need to handle the incoming channels and
requests yourself.  Fortunately, the package provides code for marshaling and
unmarshaling messages from the SSH wire format.

I decided that I would get a better performance and more predictable behavior
without needing to package the Python runtime, plus I appreciated the
stability Go would provide (fewer runtime errors), so I began developing.  What
I ended up with is [sshdog](https://github.com/Matir/sshdog), and I'm releasing it today.

sshdog supports:

- Windows & Linux
- Configure port, host key, authorized keys
- Pubkey authentication (no passwords)
- Port forwarding
- SCP (but no SFTP support)

Additionally, it's capable of being installed as a service on Windows, and
daemonizing on Linux.  It uses [go.rice](https://github.com/GeertJohan/go.rice)
to embed configuration within the resulting binary and give you a single
executable that runs the server.

**Example Usage**

```
% go build .
% ssh-keygen -t rsa -b 2048 -N '' -f config/ssh_host_rsa_key
% echo 2222 > config/port
% cp ~/.ssh/id_rsa.pub config/authorized_keys
% rice append --exec sshdog
% ./sshdog
[DEBUG] Adding hostkey file: ssh_host_rsa_key
[DEBUG] Adding authorized_keys.
[DEBUG] Listening on :2222
[DEBUG] Waiting for shutdown.
[DEBUG] select...
```

**Why sshdog?**

The name is supposed to be a riff off netcat and similar tools, as well as an
anagram for "Go SSHD".

Please, give it a try and feel free to file bugs/pull requests on the Github
project.  [https://github.com/Matir/sshdog](https://github.com/Matir/sshdog).
