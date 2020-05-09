---
layout: post
title: "Announcing TIMEP: Test Interface for Multiple Embedded Protocols"
category: Electronics
date: 2020-05-08
tags:
  - Electronics
  - Security
---

Today I'm releasing a new open source hardware (OSHW) project -- the Test
Interface for Multiple Embedded Protocols (TIMEP).  It's based around the FTDI
FT2232H chip and logic level shifters to provide breakouts, buffering, and level
conversion for a number of common embedded hardware interfaces.  At present,
this includes:

* SPI
* I2C
* JTAG
* SWD
* UART

![TIMEP](/img/timep/timep.png)

This is a revision 4 board, made using [OSHPark's](https://oshpark.com) "After
Dark" service -- black substrate, clear solder mask, so you can see every trace
on the board.  (Strangely, copper looks very matte under the solder mask,
resulting in more of a tan color than the shiny copper one might expect to see.)

It's intended to be easy to use and work with open source software, including
tools like OpenOCD and Flashrom.

Edit: I rushed to get this post out late at night, but I should've acknowledged
that this project was inspired while I was taking a [hardware security
class](https://securinghardware.com/) with [Joe
Fitzpatrick](https://twitter.com/@securelyfitz).  He also provided a review of
an early revision of the board.  If you have no idea what SPI, I2C, JTAG, and
SWD are, I can't recommend his classes enough to get started in hardware
hacking.  (Even if you do know what those are, his classes are a lot of fun.)

See the [project on GitHub](https://github.com/Matir/timep), and I hope to have
some boards available for sale on Tindie in the near future.
