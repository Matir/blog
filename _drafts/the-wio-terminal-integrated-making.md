---
layout: post
title: "The Wio Terminal - Integrated Making?"
category: Electronics
rss: false
excerpt:
    The first thing you'll notice about the Wio Terminal is it's 2.4" LCD
    screen, but under the hood, it's powered by an Atmel SAMD51 Microcontoller
    (120 MHz ARM Cortex M4F) paired with a Realtek RTL8720DN for WiFi and BLE.
    It has a 5 way switch, multiple buttons, and a Micro-SD card slot.  Embedded
    peripherals include an accelerometer, microphone, speaker, and light sensor.
    I/O is available via a Raspberry Pi compatible 40 pin header, 2 Grove
    interfaces, and USB type C.
---

*Please note: Seeed Technology Co Ltd provided the Wio Terminal for use in this
 review.  I have not been compensated in any other way for this post.*

While the Arduino and similar development boards have been available for more
than a decade, there has been a trend as of late to abstract away the hardware
aspects and allow users to focus on it at a higher level.  First, we had
standard interfaces to which you could attach "shields", "hats", "featherwings",
or other add-on boards.  Then came options like Seeed's [Grove
System](https://wiki.seeedstudio.com/Grove_System/) and SparkFun's
[Qwiic](https://www.sparkfun.com/qwiic), which were both I2C busses exposed over
a standardized connector, allowing the connection of many peripherals at once.
There's also been an expansion into development boards with built-in sensors and
outputs, like Adafruit's [Circuit
Playground](https://www.adafruit.com/index.php?main_page=category&cPath=888).
The [Wio Terminal](https://www.seeedstudio.com/Wio-Terminal-p-4509.html)
is the most sophisticated and complete incarnation of this
trend that I've seen thus far.

The first thing you'll notice about the Wio Terminal is it's 2.4" LCD screen,
but under the hood, it's powered by an Atmel SAMD51 Microcontoller (120 MHz ARM
Cortex M4F) paired with a Realtek RTL8720DN for WiFi and BLE.  It has a 5 way
switch, multiple buttons, and a Micro-SD card slot.  Embedded peripherals
include an accelerometer, microphone, speaker, and light sensor.  I/O is
available via a Raspberry Pi compatible 40 pin header, 2 Grove interfaces, and
USB type C.

<!--more-->

When Seeed Technology offered me a Wio to take a look, I thought it would be a
great idea.  I'm curious both what can be done as a standalone device and what
can be done with attached hardware.

### Demo Project

### WiFi Scanner
