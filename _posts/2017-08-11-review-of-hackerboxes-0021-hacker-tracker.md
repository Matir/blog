---
layout: post
title: "Review of HackerBoxes 0021: Hacker Tracker"
category: Electronics
date: 2017-08-11
tags:
  - Reviews
  - HackerBoxes
---

HackerBoxes is a monthly subscription service for hardware hackers and makers.
I hadn't heard of it until I was researching DEF CON 25 badges, for which they
had a box, at which point I was amazed I had missed it.  They were handing out
coupons at DEF CON and BSidesLV for 10% off your first box, so I decided to give
it a try.

[![Hacker Tracker](/img/blog/hackerboxes_0021.jpg)](http://www.instructables.com/id/HackerBoxes-0021-Hacker-Tracker/)

First thing I noticed upon opening the box was that there's no fanfare in the
packaging or design of the shipping.  You get a plain white box shipped USPS
with all of the contents just inside.  I can't decide if I'm happy they're not
wasting material on extra packaging, or disappointed they didn't do more to make
it feel exciting.  If you look at their website, they show all the past boxes
with a black "Hacker Boxes" branded box, so I don't know if this is a change, or
the pictures on the website are misleading, or the influx of new members from
hacker summer camp has resulted in a box shortage.

I unpacked the box quickly to find the following:

- Arduino Nano Clone
- Jumper Wires
- Small breadboard
- MicroSD Card (16 GB)
- USB MicroSD Reader
- MicroSD Breakout Board
- u-blox NEO 6M GPS module
- Magnetometer breakout
- PCB Ruler
- MicroUSB Cable
- Hackerboxes Sticker
- Pinout card with reminder of instructions (aka h4x0r sk00l)

If you've been trying to do the math in your head, I'll save you the trouble.
In quantity 1, these parts can be had from AliExpress for about $30.  If you're
feeling impatient, you can do it on Amazon for about $50.  Of course, the value
of the parts alone isn't the whole story: this is a curated set of components
that builds a project, and the directions they provide on getting started are
part of the product.  (I just know everyone wanted to know the cash value.)

Compared to some of their historical boxes, I'm a little underwhelmed.  Many of
their boxes look like something where I could do many things with the kit or
teach hardware concepts: for example, "0018: Circuit Circus" is clearly an effort to
teach analog circuits.  "0015 - Connect Everything" lets you connect everything
to WiFi via the ESP32.  Even when not multi-purpose, previous kits have included
reusable tools like a USB borescope or a Utili-Key.  Many seem to have an
exclusive "fun" item, like a patch or keychain, in addition to the obligatory
HackerBoxes sticker.

In contrast, the "Hacker Tracker" box feels like a unitasker: receive
GPS/magnetometer readings and log them to a MicroSD card.  Furthermore, there's
not much hardware education involved: all of the components connect directly via
jumper wires to the provided Arduino Nano clone, so other than "connect the
right wire", there's no electronics skillset to speak of.  On the software side,
while there are steps along the way showing how each component is used, a
fully-functional Arduino sketch is provided, so you don't *have* to know any
programming to get a functional GPS logger.

Overall, I feel like this kit is essentially "paint-by-numbers", which can
either be great or disappointing.  If you're introducing a teenager to
electronics and programming, a "paint-by-numbers" approach is probably a great
start.  Likewise, if this is your first foray into electronics or Arduino, you
should have no trouble following along.  On the other hand, if you're more
experienced and just looking for inspiration of endless possibilities, I feel
like this kit has fallen short.

There's one other gripe I have with this kit: there are headers on the Arduino
Nano clone and the MicroSD breakout, but the headers are not soldered on the
accelerometer or GPS module.  At least if you're going to make a simple kit,
make it so I don't have to clean off the soldering station, okay?

So, am I keeping my subscription?  For the moment, yes, at least for another
month.  Like I said, I've been impressed by past kits, so this might just be an
off month for what I'm looking for.  I don't think this kit is bad, and I'm not
disappointed, just not as excited as I'd hoped to be.  I might have to give
Adabox a try though.

As for the subscription service itself: it looks like their web interface makes
it easy to skip a month (maybe you're travelling and won't have time?) or cancel
entirely.  I'm not advocating cancelling, but I absolutely *hate* when
subscription services make you contact customer service to cancel (just so they
can try to talk you into staying longer, like AOL back in the 90s).  The site
has a nice clean feel and works well.

If anyone from HackerBoxes is reading this, I'll consolidate my suggestions to
you in a few points:

- Hook us up with patches & more stickers!  Especially a sticker that won't take
  1/4 of a laptop.  (I love the sticker from #0015 and the patch from #0018.)
- Don't have the only soldering be two tiny header strips.  Getting out the
  soldering iron just to do a couple of SPI connections is a bit of a drag.
  Either do a PCB like #0019, #0020, etc., or provide modules with headers in
  place.  (If it wasn't for the soldering, you could take this kit on vacation
  and play with just the kit and a laptop!)
- Instructables with more information on *why* you're doing what you're doing
  would be nice.  Mentioning that there's a level shifter on the MicroSD
  breakout because MicroSD cards run at 3.3V, and not the 5V from an Arduino
  Nano, for example.
- Including a part that requires a warning about you (the experts) having had a
  lot of problems with it in an introductory kit seems like a poor choice.  A
  customer with flaky behavior won't know if it's their setup, their code, or
  the part.

Overall, I'm excited to see so much going into STEM education and the maker
movement, and I'm happy that it's still growing.  I want to thank HackerBoxes
for being a part of that and wish them success even if I don't turn out to be
their ideal demographic.
