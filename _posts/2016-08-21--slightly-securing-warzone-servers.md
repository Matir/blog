---
layout: post
title: "(Slightly) Securing Wargame Servers"
category: Security
date: 2016-08-21
tags:
  - Security
  - Warzone
  - Wargames
kramdown: true
---

I was setting up some wargame boxes for a private group and wanted to reduce the
risk of malfeasence/abuse from these boxes.  One option, used by many public
wargames, is locking down the firewall.  While that's a great start, I decided
to go one step further and prevent directly logging in as the wargame users,
requiring that the users of my private wargames have their own accounts.

### Step 1: Setup the Private Accounts

This is pretty straightforward: create a group for these users that can SSH
directly in, create their accounts, and setup their public keys.

~~~ bash
# groupadd sshusers
# useradd -G sshusers matir
# su - matir
$ mkdir -p .ssh
$ echo 'AAA...' > .ssh/authorized_keys
~~~

### Step 2: Configure PAM

This will setup PAM to define who can log in from where.  Edit
`/etc/security/access.conf` to look like this:

~~~
# /etc/security/access.conf
+ : (sshusers) : ALL
+ : ALL : 127.0.0.0/24
- : ALL : ALL
~~~

This allows `sshusers` to log in from anywhere, and everyone to log in locally.
This way, users allowed via SSH log in, then port forward from their machine to
the wargame server to connect as a level.

Edit `/etc/pam.d/sshd` to use this by uncommenting (or adding) a line:

~~~
account  required     pam_access.so nodefgroup
~~~

### Step 3: Configure SSHD

Now we'll configure SSHD to allow access as needed: passwords locally, keys only
from remote hosts, and make sure we use pam.  Ensure the following settings are
set:

~~~
UsePAM yes

Match Host !127.0.0.0/24
  PasswordAuthentication no
~~~

### Step 4: Test

Restart `sshd` and you should be able to connect remotely as any user in
`sshusers`, but not any other user.  You should also be able to port forward and
check then connect with a username/password through the forwarded port.
