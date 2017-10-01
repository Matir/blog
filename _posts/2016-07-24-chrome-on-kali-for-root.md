---
layout: post
title: "Chrome on Kali for root"
category: Computer
tags:
  - Security
  - Kali Linux
date: 2016-07-24
---

For many of the tools on [Kali Linux](https://www.kali.org), it's easiest to run
them as root, so the defacto standard has more or less become to run as root
when using Kali.  Google Chrome, on the other hand, would not like to be run as
root (because it makes sandboxing harder when your user is all-powerful) so
there have been a number of tricks to get it to run.  I'm going to describe my
preferred setup here.  (Mostly as documentation for myself.)

### Download and Install the Chrome .deb file. ###

I prefer the [Google Chrome Beta](https://www.google.com/chrome/browser/beta.html)
build, but stable will work just fine too.  Download the .deb file and install
it:

```
dpkg -i google-chrome*.deb
```

If it's a fresh Kali install, you'll be missing `libappindicator`, but you can
fix that via:

```
apt-get install -f
```

### Getting a User to Run Chrome ###

We'll create a dedicated user to run Chrome, this provides some user isolation
and prevents Chrome from complaining.

```
useradd -m chrome
```

### Setting up su ###

Now we'll setup `su` to handle the passing of X credentials between the users.
We'll add `pam_xauth` to forward it, and configure root to pass credentials to
the `chrome` user.

```
sed -i 's/@include common-session/session optional pam_xauth.so\n\0/' \
  /etc/pam.d/su
mkdir -p /root/.xauth
echo chrome > /root/.xauth/export
```

### Setting up the Chrome Desktop Icon ###

All that's left now is to change the Application Menu entry (aka .desktop) to
use the following as the command:

```
su -l -c "/usr/bin/google-chrome-beta" chrome
```
