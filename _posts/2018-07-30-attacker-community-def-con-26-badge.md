---
layout: post
title: "Attacker Community DEF CON 26 Badge"
category: Electronics
date: 2018-07-30
tags:
  - Badgelife
  - Attacker Community
  - Hacker Summer Camp
---

I've spent an unhealthy amount of time over the past 6 months or so
participating in the craze that is
[#badgelife](https://twitter.com/search?q=%23badgelife).  This year, I built
badges for my Security Research Group/CTF Team: Attacker Community.  (Because
community is important when you're attacking things.)  Like last year, all of my
badges were designed, assembled, and programmed by me.  There are 24 badges this
year, each featuring 8 characters of 14-segment display goodness and bluetooth
connectivity.

<!--more-->

* TOC
{:.toc}

NOPUBLISH: badge image

## Concept ##

I spent a lot of time kicking around ideas for the badge this year.  While I
built my DEF CON 25 badge in secret (because I wanted to surprise people with
them), this year I solicited ideas from my group.  Eventually someone suggested
a "Hack the Planet" globe with a display on it, and I ran with it.

The LED displays are intended to throw back to the '80s, fitting with the DEF
CON theme of 1983, but the microcontroller features integrated Bluetooth,
bringing it to 2018.  The artwork is matte black solder mask with white silk
screen (because apparently I don't know how to do color) and all but one of the
badges has classic red LEDs.

## Design ##

I knew from the get go that I wanted to include Bluetooth functionality on the
badge.  Given the availability of powerful microcontrollers with built-in
Bluetooth, it seemed obvious that an integrated solution would be the best
option.  At first, I looked at the ESP32, but while they are cheap, the power
consumption is fairly high, and the documentation isn't as good as I would have
hoped.

Next, I looked at the nRF52 series, and decided I liked them right away.
They feature an ARM M4 core, so have an architecture I'm well familiar with, and
have a BLE 5 capable radio.  Obviously, I didn't want to build my own antenna
and matching section, so I started looking for a module as a solution.  At
first, I looked at the Rigado modules, but they were a little bit more than I
wanted to use for a small badge run (personally financed), so I was happy when I
found the somewhat cheaper Fanstel BT832 series.  I ended up going with the
BT832A, which is based on the nRF52810, a lower flash/lower RAM variant of the
popular nRF52832.

## Prototyping ##

I bought a Fanstel BT832 dev board and some 14 segment displays.  I started with
the dev board and an Adafruit 14-segment LED backpack.  This allowed me to get
some experience with the nRF52 SDK, and make sure the general concept was sound
without sending out for a custom PCB.

In preparing for the first prototype, I looked for an appropriate LED driver for
the 120 LED segments on the 8 characters (organized as the 8 common groups of 15
LEDs).  A typical way to drive these is by rapidly pulsing through the common pins
(common anode in this case) and as each common pin is activated, the driver
outputs the 15 signals for the various LEDs.  Surprisingly, I found very little
in the way of an easy to use driver, except for the Holtek HT16K33 used in the
Adafruit backpack.

There were two problems with the Holtek chip, however.  First, it's relatively
hard to obtain -- it can't be purchased on Digikey, Mouser, Jameco, or Arrow.
The only source I could find was AliExpress, which is always a dicey
proposition.  Even at best, it often takes several weeks to receive the product.
At worst, it never shows up, or the product is not what was advertised.

Secondly, the HT16K33 is a chip designed for 5V operation, with a specified
range of 4.5-5.5V.  My badge design was targeting a 3V supply.  I began by
testing my protoboard prototype and seeing how low I could drive the prototype
and still have everything working.  I was pleasantly surprised (and somewhat
amazed) to see that the HT16K33 kept working until the voltage had dropped so
low that the LEDs stopped lighting due to their forward voltage (~1.8V).  Still,
I had no way to know if that was specific to this one chip or if all of the
chips would behave similarly.  Still, since I had this working, I pressed onward
with my design.

I designed a full-scale prototype with the NRF module, the 4 displays (2
characters each), the HT16K33 LED driver, and a number of test points to measure
voltage, current, etc.  I sent the board design off to JLCPCB.  (I'd heard good
things, figured it was a good opportunity to try them out.)

About two days later, I realized I had made a terrible mistake in the design:
while I had properly laid out the pinout of the LED displays, I had neglected to
take into account the physical overhang of the displays beyond the pins.
There's no way all 4 displays would physically fit on the board!  I debated
immediately redoing the board, but decided to try to "make it work" in the
interests of time.

## Assembly ##

## Android App ##

## Lessons Learned ##
