---
layout: post
title: "2017 Christmas Ornament"
category: Electronics
date: 2017-12-25
tags:
  - Making
  - Electronics
  - Christmas
---

After playing around with a [custom DEF CON
badge](/2017/07/31/hacker-summer-camp-2017-xxv-badge.html), I wanted to do
another electronics project just for fun.  What better time to share electronics
with others than Christmas?  So I decided to do a custom ornament for friends
and family.

Though it shared some characteristics with my DEF CON badge (blinken lights,
battery powered, etc.), the similarities ended there.  In this case I want
something lightweight (it's going on a tree branch), simple (the XXV badges took
a *long* time to assemble by hand), and that could run off a coin cell battery
for days.

Not being the most artistic of individuals, I went with a simple snowflake
design and 6 LEDs at the points.  At first, I wanted to do white LEDs, but since
they have a forward voltage around 3.2V, that wouldn't work well with a single
3V coin cell, so I settled for 1.8V Red LEDs.  (The battery will be unable to
produce much current at all long before it reaches 1.8V.)

![Snowflake Ornament Front](/img/blog/ornament2017/ornament_front.jpg)

The ornament base is a red soldermask PCB with gold-plated (ENIG) copper.  The
boards were produced at [Elecrow](https://www.elecrow.com/) and I hand assembled
the parts.  The microcontroller is the ATTiny2313A, chosen both for low power
consumption and low cost.  (Driving 6 LEDs doesn't take much in the way of CPU.)
I chose not to use the ATTiny25/45/85 series because I didn't want to deal with
multiplexing pins to drive the LEDs and in-circuit programming (ICSP) header.

![Schematic](/img/blog/ornament2017/schematic.png)

The schematic is pretty straight forward.  There's a battery holder and a couple
of power supply capacitors (due to PWM of the lights, I didn't want the input
voltage bouncing around too much), the microcontroller, a single resistor
network, and the 6 LEDs which are on the front of the board.  The full bill of
materials includes:

```
Label   Description
---------------------------------------------------------------
BT1     20mm SMD Coin Cell Holder
C1      0.1uF Ceramic Capacitor (0805)
C2      10uF Ceramic Capacitor (0805)
U1      ATTiny2313A (QFN20)
RN1     Resistor Network, 8 Independent, 100 Ohm Each
D1-D6   Red SMD LED (0805)
J1      2x3 Header, SMD, 2.54mm Spacing (AVR ICSP)
```

On the actual ornaments, the ICSP header is unpopulated -- I manually held a
connector to it to program each one.  I left the connector in a standard format
instead of a pogo pin arrangement in case any of my recipients wanted to hack on
the firmware.  (Since it's Open Source.)

![Snowflake Ornament Back](/img/blog/ornament2017/ornament_back.jpg)

It was a fun little project and I'm already considering how I can improve for a
new one next year.  Full schematics, design files, and source code are [on
Github](https://github.com/Matir/2017-ornament).
