---
layout: post
title: "PSA: Typos in mkfs commands are painful"
date: 2014-10-20 14:19:40 +0000
permalink: /2014/10/20/psa-typos-in-mkfs-commands-are-painful/
category: Computer
tags:
  - System Administration
  - Ubuntu
  - Lessons Learned
redirect_from:
  - /blog/psa-typos-in-mkfs-commands-are-painful/
---
TL;DR: I apparently typed `mkfs.vfat /dev/sda1` at some point.  Oops.

So I rarely reboot my machines, and last night, when I rebooted my laptop (for graphics card weirdness) Grub just came up with:

    Error: unknown filesystem.
    grub rescue>

WTF, I wonder how I borked my grub config?  Let's see what happens when we ls my /boot partition.

    grub rescue>ls (hd0,msdos1)
    unknown filesystem

Hrrm, that's no good.  An `ls` on my other partition isn't going to be very useful, it's a LUKS-encrypted LVM PV.  Alright, time for a live system.  I grab a Kali live USB (not because Kali is necessarily the best option here, it's just what I happen to have handy) and put it in the system and boot from that.  `file` tells me its an `x86 boot sector`, which is not at all what I'm expecting from an ext4 boot partition.  It slowly dawns on me that at some point, intending to format a flash drive or SD card, I must've run `mkfs.vfat /dev/sd`**`a`**`1` instead of `mkfs.vfat /dev/sd`**`b`**`1`.  That one letter makes all the difference.  Of course, it turns out it's not even a valid FAT filesystem... since the device was mounted, the OS had kept writing to it like an ext4 filesystem, so it was basically a mangled mess.  `fsck` wasn't able to restore it, even pointing to backup superblocks: it seems as though, among other things, the root inode was destroyed.

So, at this point, I basically have a completely useless `/boot` partition.  I have approximately two options: reinstall and reconfigure the entire OS, or try to fix it manually.  Since it didn't seem I had much to lose and it would probably be faster to fix manually (if I could), I decided to give door #2 a try.

First step: recreate a valid filesystem.  `mkfs.ext4 -L boot /dev/sda1` takes care of that, but you better believe I checked the device name about a dozen times.  Now I need to get all the partitions and filesystems mounted for a chroot and then get into it:

    % mkdir /target
    % cryptsetup luksOpen /dev/sda5 sda5_crypt
    % vgchange -a y
    % mount /dev/mapper/ubuntu-root /target
    % mount /dev/sda1 /target/boot
    % mount -o bind /proc /target/proc
    % mount -o bind /sys /target/sys
    % mount -o bind /dev /target/dev
    % chroot /target /bin/bash

Now I'm in my system and it's time to replace my missing files, but how to figure out what goes there?  I know there are at least files for grub, kernels, initrds.  I wonder if dpkg-query can be useful here?

    # dpkg-query -S /boot
    linux-image-3.13.0-36-generic, linux-image-3.13.0-37-generic, memtest86+, base-files: /boot

Well, there's a handful of packages.  Let's reinstall them:

    # apt-get install --reinstall linux-image-3.13.0-36-generic linux-image-3.13.0-37-generic memtest86+ base-files

That's gotten our kernel and initrd replace, but no grub files.  Those can be copied by `grub-install /dev/sda`.  Just to be on the safe side, let's also make sure our grub config and initrd images are up to date.

    # grub-install /dev/sda
    # update-grub2
    # update-initramfs -k all -u

At this point, I've run out of things to double check, so I decide it's time to find out if this was actually good for anything.  Exit the chroot and unmount all the filesystems, then reboot from the hard drive.

...

It worked!  Fortunately for me, `/boot` is such a predictable skeleton that it's relatively easy to rebuild when destroyed.  Here's hoping you never find yourself in this situation, but if you do, maybe this will help you get back to normal without a full reinstall.
