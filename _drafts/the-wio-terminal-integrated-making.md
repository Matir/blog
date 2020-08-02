---
layout: post
title: "The Wio Terminal - Integrated Making?"
category: Electronics
rss: false
tags:
  - Sponsored
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

![Wio Terminal](/img/wio/wio_main.png)

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

![Box Contents](/img/wio/box_contents.png)

Inside the box, you find the Wio Terminal itself, with a plastic peel to protect
the screen in shipping (it was also inside a small plastic bag, removed for this
photo), a user manual, a short USB-C cable, and a spare 5-way switch hat.  The
manual is very brief and beyond covering where to put the power cord, I'd
suggest to only use the online documentation instead.

The [documentation on Seeed's
Wiki](https://wiki.seeedstudio.com/Wio-Terminal-Getting-Started/) is really
quite good.  There is some setup necessary to get ready to use the Wio Terminal
with the Arduino IDE, but it's quite straightforward.  I first uploaded the
standard Arduino "blink" sketch just to verify that I had everything working
correctly.  This did, in fact, blink the blue status LED next to the USB-C port
on the Wio Terminal.

## WiFi Scanner

### WiFi Setup

In order to use the WiFi functionality of the Wio Terminal, you must upload the
latest firmware to the WiFi chipset.  It's well
[documented](https://wiki.seeedstudio.com/Wio-Terminal-Network-Overview/) on
their wiki, but basically it boils down to flashing a special Arduino sketch,
then running a tool that uploads the firmware.  The Arduino sketch appears to
make the main processor just bridge traffic between the serial port on USB and
the serial port on the RTL8720.

I started by flashing their WiFi scanning sketch and noticed that it was
inconsistently showing whether given networks were encrypted.  Additionally,
examining the results of `WiFi.encryptionType` for a network seemed to provide
non-sensical values, varying quite a bit.  I soon discovered a bug in their
`atUnified` library where it did not copy the encryption field from the scan
results, so I was just getting noise off the stack.  I've submitted a [pull
request](https://github.com/Seeed-Studio/Seeed_Arduino_atUnified/pull/2) to
their library to fix the bug.

From digging into the firmware, I discovered that the RTL8720D firmware you load
provides essentially the same command set as offered by the ESP32/ESP8266 in
`AT` mode, which is a pretty clever way to allow a lot of existing Arduino code
to be ported relatively easily.  (And explains why libraries with `esp` in the
name are needed for WiFi support on the Wio Terminal.)

### Integrating LCD

The Wio Terminal's LCD is compatible with the
[TFT\_eSPI](https://github.com/Bodmer/TFT_eSPI) library.  Drawing to the screen
is quite easy, although like with any other SPI-based display, you will not be
getting super high framerates.  I started rendering the WiFi scans on the
display with only about 20 minutes of coding time, most of which was figuring
out how to draw a box containing text in the middle of the screen (which turns
out to be trivial).

## Little Quirks

There were a couple of things I found a bit quirky or unusual while working with
the Wio Terminal.  None are show-stoppers, just things you have to work around.
Note that my expectation of the orientation of the terminal is screen facing
you, 5-way switch in lower right corner, as is also shown in most of their
marketing materials.

The buttons on top are ordered from **right to left**.  So button "A" is the
furthest right when looking at it head on.  This is backwards of my expectation,
and neither the included manual nor the [wiki page on configurable
buttons](https://wiki.seeedstudio.com/Wio-Terminal-Buttons/) explains otherwise.

For the **screen to be "upright"** in the same orientation as described above,
you need to call `tft.setRotation(3);`.  Again, not a big deal, just something
to be aware of as you develop with the Wio Terminal.

## About Seeed

Seeed provided the following snippet to describe their offerings:

>    [About Seeed Studio](http://www.seeedstudio.com){:rel='nofollow'} Seeed is
>    the IoT hardware enabler providing services over 10 years that empower
>    makers to realize their projects and products. Seeed offers a wide array of
>    hardware platforms and sensor modules ready to be integrated with existing
>    IoT platforms and one-stop [PCB
>    fabrication](https://www.seeedstudio.com/fusion_pcb.html){:rel='nofollow'}
>    and [PCB assembly
>    service](https://www.seeedstudio.com/prototype-pcb-assembly.html){:rel='nofollow'}.
>    Seeed Studio provides a wide selection of electronic parts including
>    [Arduino](https://www.seeedstudio.com/category/Arduino-c-1001.html){:rel='nofollow'},
>    [Raspberry
>    Pi](https://www.seeedstudio.com/Raspberry-pi-c-1010.html){:rel='nofollow'}
>    and many different development board platforms  Especially the [Grove
>    System](https://www.seeedstudio.com/grove.html){:rel='nofollow'} help
>    engineers and makers to avoid jumper wires problems. Seeed Studio has
>    developed more than 280 Grove modules covering a wide range of applications
>    that can fulfill a variety of needs.
