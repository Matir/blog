---
layout: post
title: "Pi Zero as a Serial Gadget"
category: Linux
date: 2017-05-21
tags:
  - Raspberry Pi
  - Linux
  - Embedded
---

I just got a new Raspberry Pi Zero W (the wireless version) and didn't feel like
hooking it up to a monitor and keyboard to get started.  I really just wanted a
serial console for starters.  Rather than solder in a header, I wanted to be
really lazy, so decided to use the USB OTG support of the Pi Zero to provide a
console over USB.  It's pretty straightforward, actually.

* Steps
{:toc}

Install Raspbian on MicroSD
---------------------------

First off is a straightforward "install" of Raspbian on your MicroSD card.  In
my case, I used `dd` to image the img file from Raspbian to a MicroSD card in a
card reader.

    dd if=/home/david/Downloads/2017-04-10-raspbian-jessie-lite.img of=/dev/sde bs=1M conv=fdatasync

Mount the /boot partition
-------------------------

You'll want to mount the boot partition to make a couple of changes.  Before
doing so, run `partprobe` to re-read the partition tables (or unplug and replug
the SD card).  Then mount the partition somewhere convenient.

    partprobe
    mount /dev/sde1 /mnt/boot

Edit /boot/config.txt
---------------------

To use the USB port as an OTG port, you'll need to enable the `dwc2` device tree
overlay.  This is accomplished by adding a line to `/boot/config.txt` with
`dtoverlay=dwc2`.

    vim /mnt/boot/config.txt
    (append dtoverlay=dwc2)

Edit /boot/cmdline.txt
----------------------

Now we'll need to tell the kernel to load the right module for the serial OTG
support.  Open `/boot/cmdline.txt`, and after `rootwait`, add
`modules-load=dwc2,g_serial`.

    vim /mnt/boot/cmdline.txt
    (insert modules-load=dwc2,g_serial after rootwait)

When you save the file, make sure it is all one line, if you have any line
wrapping options they may have inserted newlines into the file.

Mount the root (/) partition
----------------------------

Let's switch the partition we're dealing with.

    umount /mnt/boot
    mount /dev/sde2 /mnt/root

Enable a Console on /dev/ttyGS0
-------------------------------

`/dev/ttyGS0` is the serial port on the USB gadget interface.  While we'll get a
serial port, we won't have a console on it unless we tell systemd to start a
`getty` (the process that handles login and starts shells) on the USB serial
port. This is as simple as creating a symlink:

    ln -s /lib/systemd/system/getty@.service /mnt/root/etc/systemd/system/getty.target.wants/getty@ttyGS0.service

This asks systemd to start a `getty` on `ttyGS0` on boot.

Unmount and boot your Pi Zero
-----------------------------

Unmount your SD card, insert the micro SD card into a Pi Zero, and boot with a
Micro USB cable between your computer and the OTG port.

Connect via a terminal emulator
-------------------------------

You can connect via the terminal emulator of your choice at 115200bps.  The Pi
Zero shows up as a "Netchip Technology, Inc. Linux-USB Serial Gadget (CDC ACM
mode)", which means that (on Linux) your device will typically be
`/dev/ttyACM0`.

    screen /dev/ttyACM0 115200

Conclusion
----------

This is a quick way to get a console on a Raspberry Pi Zero, but it has
downsides:

- Provides only console, no networking.
- File transfers are "difficult".
