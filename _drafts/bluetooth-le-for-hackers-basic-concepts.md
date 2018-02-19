---
layout: post
title: "Bluetooth LE for Hackers: Basic Concepts"
category: Security
series: "Bluetooth LE for Hackers"
tags:
  - Security
  - Bluetooth LE
kramdown: true  # Requires kramdown
---

This is the first post in a series on Bluetooth Low Energy for hackers.  I am no
expert in Bluetooth or BLE, but I'm taking a hands-on approach to learning about
it, and I decided to document my lessons as I go along.  There seems to be
relatively little information out there for hackers trying to play with or break
Bluetooth LE-based systems, so I'm going to try to consolidate what little there
is and add my own notes as I go.  Feel free to reach out if you find any errors
or have any suggestions for improvements.

<!--more-->

* TOC
{:toc}

## Bluetooth Low Energy vs Bluetooth Classic ##

If you have any familiarity with Bluetooth Classic and are expecting that
knowledge to translate to Bluetooth Low Energy (BLE), you'll probably be sorely
disappointed.  While there are *some* similarities, the two protocols are
incredibly different, and are so for good reason.  A few elements of the
physical & link layer are the same, and some addressing related components, but
otherwise you'll find little similarity between Bluetooth Classic and Bluetooth
Low Energy.

First, a note on use cases.  Bluetooth Low Energy is best suited for exchanging
small pieces of information (relatively) infrequently.  Specifically, BLE is a
poor choice for audio transmission: either for Bluetooth Speakers or Bluetooth
headsets.  Likewise, it's not designed for sending IP network traffic over
Bluetooth Low Energy, unlike the PAN profile for Bluetooth Classic.

The two protocols use the same part of the spectrum as WiFi: from about 2400 to
2480 MHz (otherwise known as 2.4GHz).  Bluetooth Classic divides this into 79
channels, while Bluetooth Low Energy utilizes 40 channels in that space.  Both
use frequency hopping within this spectrum, but the frequency hopping for
Bluetooth Low Energy is dramatically simpler than that for Bluetooth Classic.
Both BLE and Bluetooth Classic Basic Data rate use the [same
modulation](https://en.wikipedia.org/wiki/GFSK), but otherwise there's little
physical comparison.

Logically, both Bluetooth Classic and Bluetooth LE use the same addresses for
devices.  I'll cover addressing in more detail later on, but the main point I'd
like to make here is that if you have a device that supports both Bluetooth
Classic and Bluetooth Low Energy (like most USB adapters starting with Bluetooth
4.0), they'll use the same fixed address for both protocols.  (Modulo some
details below.)

Beyond this point, I won't compare to Bluetooth Classic any further.  The
remainder of this series is written without assuming any pre-existing knowledge
about either flavor of Bluetooth.

## Bluetooth Low Energy (BLE): A Brief History ##

Bluetooth Low Energy started out as a Nokia project named Wibree in about 2001,
starting from work on Bluetooth Classic.  Their goals were to reduce both power
consumption and implementation cost for a short-range point-to-point wireless
technology.  In 2007, Nokia negotiated with the rest of the [Bluetooth
SIG](https://www.bluetooth.com) (the working group responsible for the Bluetooth
specifications) to have Wibree included in the Bluetooth specification.  This
was first named Bluetooth Smart, but was renamed to Bluetooth Low Energy for its
first official release as part of the Bluetooth 4.0 specification, adopted [at
the end of
2009](https://www.bluetooth.com/news/pressreleases/2009/12/17/sig-introduces-bluetooth-low-energy-wireless-technologythe-next-generation-of-bluetooth-wireless-technology).

BLE has been improved with each generation of the Bluetooth Core specification,
with the latest release in Bluetooth 5 increasing broadcast power, speed, and
maximum data length per packet.

## Connection States ##

Before getting into details about the Bluetooth LE stack, there are some basic
concepts you should be familiar with.  A Bluetooth LE device can be
**advertising** or it can be **connected**.  When **advertising**, devices are
communicating with any device that can receive their radio signal.  This is
essentially a broadcast mode of operation.  When **connected**, a device is
maintaining a point-to-point communication between two BLE endpoints.  Each
connection has a unique identifier and stock hardware will drop Bluetooth LE
packets that are neither advertising packets nor part of the connection(s) the
endpoint is participating in.  Different protocols are used for the advertising
and connected phases, and I'll provide details on each in turn.

## The Physical & Link Layer ##

There are only a few things that the IoT hacker need know about the physical
layer of Bluetooth LE.  (If you're planning to implement your own hardware, I
suggest reading the current version of the Bluetooth Core Specification instead
of this blog post.)  Mostly these deal with the spectrum segments (channels) and
frequency hopping used within the channels specified.

### Spectrum ###

Bluetooth Low Energy divides the 2400-2480 MHz spectrum into 40
channels[^ble6a2], each 2 MHz wide.  Of these 40 channels, 37 (0-36) are used
for data during connections, and 3 (37-39) are used for advertising data.  The
advertising channels are exclusively used by devices not in a connected state;
similarly the data channels are only used by devices in a connected state.  The
connection request can take place on any of the 3 advertising channels.

Of note is that this is the same frequency segment occupied by WiFi, Bluetooth
Classic, 802.15.4 (Zigbee, Zwave, etc.) and a host of other unlicensed
technologies.  The ease of using 2.4 GHz has also turned it into something of a
mess with many competing technologies in the same spectrum.  The designers of
Bluetooth Low Energy used a modulation designed to try to reduce this
interference risk, but of course that's no guarantee.  Consequently, BLE devices
must be prepared to deal with dropped packets and congested RF spectrum.

![BLE Spectrum](/img/blog/ble/spectrum.svg)

Notice that, although all of the data channels are numbered in order, they are
broken up by the advertising channels.  Presumably this was done so that if
there was heavy interference at one end of the spectrum or the other, it would
not cover all of the advertising channels simultaneously.  It's not really
important to know the specific frequencies, but knowing approximately how it's
spaced out might help you understand if you run into interference problems.

### Frequency Hopping ###

Within the 37 data channels, the connection regularly changes channel according
to a simple algorithm.  During the connection phase, several parameters are
derived, including the frequency with which channels will be changed
and the increment of the hop (i.e., by how many channels will the
current channel change on each hop).  Any radio
attempting to follow the connection and listen to it will need to perform the
same hopping as the radios involved in the connection.

The algorithm for hopping in Bluetooth Low Energy involves simple modular
arithmetic.  For almost all devices, all channels are used, although a device
can advertise that it wishes to use fewer than 37 channels, in which case an
alternative algorithm is used to remap the hopping to the available
channels.[^ble6b4582]

<!--TODO: consider mathjax-->

    nextChannel = (currentChannel + hopIncrement) mod 37

The mathematically inclined may notice that 37 is a prime number.  This has the
effect of ensuring that (eventually) every channel is used by the connection,
because all `hopIncrement` values are relatively prime to a prime number.

### Packet Format ###

All Bluetooth Low Energy packets use a single Link-Layer packet
format[^ble6b21], consisting of four fields:

1. A 1-octet preamble.
2. A 4-octet Access Address.
3. A variable-length protocol data unit (PDU).
4. A 3-octet CRC calculated over the PDU.

![Link Level Packet Format](/img/blog/ble/linklevel.svg)

The preamble is used to synchronize the transmitter and the receiver and always
consists of a pattern of alternating zeros and ones.

The access address of all advertising packets is `0x8E89BED6`, which cannot be
used for data packets within a connection.[^ble6b212]
(I have no idea how this value was chosen.  The spec does not give any
rationale, although there are some technical limitations on access address
involving the number of transitions between 0s and 1s and the invidiual values.)
The Access Address for connections is random and selected when the connection is
created.

The PDU format varies between advertising and connected state packets.  This is
the data field for the link-layer protocol, and encapsulates a different
protocol when advertising versus connected.  In BLE versions 4.0 and 41., the
PDU could be anywhere from 2 to 39 bytes long.  Since version 4.2, it can go up
to 257 bytes in length.

## Device Addressing ##

Bluetooth Low Energy uses an addressing scheme that is similar to that used for
ethernet addressing.  Addresses are 48 bits in length and should be unique to
each device.  There are multiple addressing schemes available: public, static,
and private.

In public addressing, each device has a 48-bit address divided into two
portions, each 3 octets (24 bits) long.  The upper 24 bits is an IEEE-assigned
OUI that identifies the manufacturer, and the lower 24 bits is uniquely assigned
to each device by the manufacturer.  Per the Bluetooth Core Specification, these
addresses must be assigned in accordance with IEEE 802[^ble6b13] (which also
specifies ethernet addressing).  Most peripheral devices will operate with their
public address when advertising.

To help address privacy concerns, there are two random addressing schemes.  A
static address is a random 48 bit address when the device starts up, but remains
static throughout that operating cycle.  A private address is a random address
that is typically used for a single connection or a time-limited period of
advertising/broadcasting.  These addresses can be generated using an encryption
key so that a partner device can predict the private addresses, but other
devices cannot track the single Bluetooth beacon across operations.

## References ##

[^ble6a2]: Bluetooth Core Specification, Version 4.0, Volume 6, Part A,
    Section 2

[^ble6b4582]: Bluetooth Core Specification, Version 4.0, Volume 6, Part B,
    Section 4.5.8.2

[^ble6b21]: Bluetooth Core Specification, Version 4.0, Volume 6, Part B,
    Section 2.1

[^ble6b212]: Bluetooth Core Specification, Version 4.0, Volume 6, Part B,
    Section 2.1.2

[^ble6b13]: Bluetooth Core Specification, Version 4.0, Volume 6, Part B,
    Section 1.3
