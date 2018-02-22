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

This will be highly information-dense, and may include information that doesn't
seem readily useful, but I'm highlighting the information necessary for those in
information security to understand communications between Bluetooth Low Energy
devices, perform audits of BLE, and get started with BLE hacking.  I've omitted
a *lot* of the details of each protocol layer, and if you really want to
understand it all, you'll need to take a look at the Bluetooth Core
Specification.

<!--more-->

Since this is a network protocol, the correct term for units of 8 bits in length
is [octet](https://en.wikipedia.org/wiki/Octet_(computing)), since a byte is
technically a host-specific definition.  However, almost all systems (especially
those that would use Bluetooth LE) use an 8-bit byte, so if I write byte
somewhere, please know that it's an 8-bit byte or an octet.

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

BLE also uses a subset of the host-level protocols that are used by Bluetooth
Classic, but in many cases, they have been simplified for the use of Bluetooth
Low Energy.  This includes the Generic Access Profile and the Attribute
Protocol.

Beyond this point, I won't compare with Bluetooth Classic any further.  The
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
maximum data length per packet.  The Version 5 specification stretches to a
massive 2822 pages!

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

All multi-byte sequences in the Bluetooth LE Packet and PDU format are
little-endian unless otherwise noted.

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
channels.[^ble6b458]

<!--TODO: consider mathjax-->

    nextChannel = (currentChannel + hopIncrement) mod 37

The mathematically inclined may notice that 37 is a prime number.  This has the
effect of ensuring that (eventually) every channel is used by the connection,
because all `hopIncrement` values are relatively prime to a prime number.

### Packet Format ###

All Bluetooth Low Energy packets use a single Link-Layer packet
format[^ble6b21], consisting of four fields:

![Link Level Packet Format](/img/blog/ble/linklevel.svg){:.right}

1. A 1-octet preamble.
2. A 4-octet Access Address.
3. A variable-length protocol data unit (PDU).
4. A 3-octet CRC calculated over the PDU.

{:.clear}
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
PDU could be anywhere from 2 to 39 octets long.  Since version 4.2, it can go up
to 257 octets in length.

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

## Advertising (GAP) ##

When advertising, devices use a protocol called Generic Access Profile.  As
mentioned previously, all GAP advertising packets will have the access address
of `0x8E89BED6`.  They will also be operating on channels 37, 38, and 39
exclusively.  GAP defines four roles for devices operating as Low Energy
devices[^ble3c222]:

Broadcaster
: A broadcaster is a device that is sending advertising events.
Observer
: An observer is a device receiving (observing) advertising events.
Peripheral
: A peripheral is a device that accepts connections via the connection
establishment procedures
Central
: A central device establishes connections with peripherals.

These roles are not mutually exclusive.  In fact, some hardware supports
operating in multiple such roles concurrently.  Even when not operated
concurrently, it's common for devices to transition roles.  For example, when
you're trying to pair a smartwatch with your phone, the phone will initially act
as an *observer*, looking for the smartwatch, which is a *broadcaster*.  Once
you select the device to pair with on your phone, the phone's role becomes that
of a *central device*, and when the connection request is received by the watch,
it becomes a *peripheral* to the phone.

Other devices may be capable of operating only in a single role.  Bluetooth
Beacons (used for providing location information, or context relevant to the
area) may only be capable of operating as a broadcaster.  (In reality, most can
also become a peripheral in order to support configuration changes.)

When advertising/broadcasting, there is no option for Bluetooth LE Security on
the connection, because the device cannot perform key distribution.[^ble3c911]
Consequently, any effort at security (encryption or authentication) on the
advertising data would have to be performed at the application level.  (However,
this is rarely, if ever, done.)

### Packet Format ###

All advertising PDUs are defined to be from 2-39 octets in length (though in
practice, all advertising PDU types result in a length of at least 8 octets) and
are encapsulated in the payload of the Bluetooth Link Layer packet previously
described.  The first 16 bits are a header that includes 4 bits for the PDU type
and 6 bits for the length.  There are also two bits that indicate if the RX and
TX addresses included in the PDU are public or private (TxAdd and RxAdd).  These
bits are set to one if the respective address included in the PDU is a
random/private address.  The remainder is payload that varies depending on the
PDU type.[^ble6b23]  (Described below.)

![Advertising PDU](/img/blog/ble/adv_pdu.svg)

The defined PDU types for advertising PDUs are[^ble6b23]:

| ------- | ----------------- | -------------------------------------- |
| Value   | Type              | Use                                    |
| ------- | ----------------- | -------------------------------------- |
| `0x00`  | `ADV_IND`         | Connectable Undirected Advertising     |
| `0x01`  | `ADV_DIRECT_IND`  | Connectable Directed Advertising       |
| `0x02`  | `ADV_NONCONN_IND` | Non-Connectable Undirected Advertising |
| `0x03`  | `SCAN_REQ`        | Scan Request                           |
| `0x04`  | `SCAN_RSP`        | Scan Response                          |
| `0x05`  | `CONNECT_REQ`     | Connection Request                     |
| `0x06`  | `ADV_SCAN_IND`    | Scannable Undirected Advertising       |
| ------- | ----------------- | -------------------------------------- |

All other values are currently reserved.

### Advertising Packets ###

`ADV_IND` PDUs are the most flexible advertising packet.  These signify an
advertising message for any listening observer for a device that is capable of
sustaining a connection.  `ADV_IND` PDUs contain a payload consisting of the
advertising address (6 octets -- either the public or random device address of
the device doing the advertising) and optional Advertising Data (0-31 octets).

![ADV_IND PDU](/img/blog/ble/adv_ind_pdu.svg)

`ADV_DIRECT_IND` is a directed advertising message: rather than being sent for
the benefit of any observer, the message contains both the Advertiser address (6
octets) and the initiator's address (6 octets).  Both addresses may be either
public or random, as indicated in the TxAdd and RxAdd fields. `ADV_DIRECT_IND`
packets are most often sent after a connection has been lost with a previously
connected host, and are used by the peripheral wanting to re-establish a
connection.  This packet does *not* contain any additional Advertising Data.

`ADV_NONCONN_IND` PDUs are structurally identical to `ADV_IND` PDUs, but signify
that the advertiser is not available for connections.

`ADV_SCAN_IND` PDUs are structurally identical to `ADV_IND` PDUs, but are for
non-connectable devices that have additional information available to active
scanners.

Almost all devices I have seen use either `ADV_IND` or `ADV_SCAN_IND` for
advertising packets. Detailed information about each PDU can be found in the BLE
spec.[^ble6b23]

### Advertising Data ###

Many packet types include an Advertising Data field.  This allows a host to
provide information directly in the advertising packets.  Advertising Data
structures are not unique to Bluetooth Low Energy and are shared with Bluetooth
Classic.  Advertising Data (contained in `ADV_IND`, `ADV_NONCONN_IND`,
`ADV_SCAN_IND`, and `SCAN_RSP` PDUs) consists of zero or more repetitions of the
AD structure.  Each AD structure is a 1 octet length, a 1 octet type, and
length-1 octets of data.  (For some reason, the type field is counted in the
length, so length will be a minimum of 1 even with empty data.)[^ble3c11]

![Advertising Data](/img/blog/ble/adv_data.svg)

The data types for the advertising data are defined in the [GAP Assigned
Numbers](https://www.bluetooth.com/specifications/assigned-numbers/generic-access-profile)
document.  Some of the more commonly seen values include:

| ------ | -------------------------------------------- |
| Value  | Data Type                                    |
| ------ | -------------------------------------------- |
| `0x03` | Complete List of 16-bit Service Class UUIDs  |
| `0x08` | Shortened Local Name                         |
| `0x09` | Complete Local Name                          |
| `0x16` | Service Data                                 |
| `0xFF` | Manufacturer Specific Data                   |
| ------ | -------------------------------------------- |

### Scanning ###

There are two kinds of scanning possible in Bluetooth Low Energy.  **Passive**
scanning involves listening on channels 37, 38, and 39 for advertising packets
broadcast by broadcasters & advertising peripherals.  Passive scanners send no
packets and can only get the information that is shared by the
broadcaster/peripheral in the 39 octets available for data in the advertising
packet.

**Active** scanners, on the other hand, actively participate in the scanning
process.  In addition to listening for advertising packets on channels 37-39,
active scanners can interrogate the devices they find for more information.
This is done from a central device by sending a `SCAN_REQ` packet to the
peripheral, which will respond with a `SCAN_RSP` containing more information
about the device or the device status.  Note that, in GAP terminology, there are
strictly "peripheral" and "central" roles involved in this -- since they have
gone interactive, they are no longer considered broadcaster/observer.

The `SCAN_REQ` PDU has 12 octets of content: the address of the device sending
the scanning request followed by the advertising address of the device being
scanned.  The `SCAN_REQ` should only be sent to a device that is actively
advertising with `ADV_IND` or `ADV_SCAN_IND` packets.

The `SCAN_RSP` PDU is the response to a scan request and allows the advertising
device to provide more information than was included in the original advertising
packets.  The format of the `SCAN_RSP` PDU payload is identical to `ADV_IND`:
the 6-octet advertising address followed by scan response data (in the format of
Advertising Data).

### Initiating Connections ###

In order to initiate a connection, a central device will send a packet containg
a `CONNECT_REQ` PDU to the peripheral it would like to connect to.  This packet
is sent on one of the advertising channels and is formatted as an advertising
(GAP) packet.  In some documentation, `CONNECT_REQ` is also referred to as the
initiating PDU because it initiates connections.

The packet contains the device address of the device initiating the connection
(6 octets), the device address of the advertising device (the peripheral; 6
octets) and 22 octets describing connection parameters (called `LLData` for Link
Layer Data).  Note that there is essentially no negotiation of the parameters:
the connection request is established, and if the peripheral can meet the
request (and would like to connect with this central device) it will do so using
the parameters chosen by the central device.[^ble6b233]

The Link Layer data specifies a number of items:

* The Access Address (`AA`, 4 octets) to be used for the connection.  While all
  advertising packets use the access address `0x8E89BED6`, all connections use a
  different access address, selected by the central device.  There are some
  constraints on the access address for hardware reasons, but it's generally a
  random 4-byte number.[^ble6b212]
* The `CRCInit` field (3 octets) is an initializer for the CRC over the packets
  of the connection.
* The `WinSize` (1 octet) and `WinOffset` (2 octets) specify variables for the
  transmit window of the link layer.
* The `Interval` (2 octets), `Latency` (2 octets) and `Timeout` (2 octets)
  values all specify parameters dealing with the timing of the connection.  The
  interval is used between subsequent connection round trips and affects
  frequency hopping as well.
* The Channel Map (`ChM`, 5 octets) is a bitmap of the channels to be used by
  the connection.  Channel 0 is the LSB and Channel 36 is in the 37th position.
  Almost all connections attempt to use all of the available channels, so this
  nearly always has value `0x1fffffffff`.[^ble6b141]  The BLE spec requires the
  value to have at least two bits set, so no connection just sits on a single
  channel forever.[^ble6b458]
* The Hop field (5 *bits*) contains the amount that is added to the current
  channel number (modulo 37) for each channel hop.  If this value is not
  available in the Channel Map, it is remapped to the available
  channels.[^ble6b458]
* The SCA field (3 *bits*) provides information on the clock accuracy of the
  master ot help compensate for clock jitter.

![CONNECT_REQ PDU](/img/blog/ble/connect_req_pdu.svg)

## Coming up in the BLE for Hackers Series ##

This will be a series of several posts that will discuss a variety of additional
topics:

* Data exchange when connected (GATT and the Attribute Protocol)
* BLE Security Design (and Practice)
* Exploring BLE Devices using stock tools
* Exploring BLE Devices using the Ubertooth One
* Approach to assessing BLE devices

In the next post, we'll look at how connections are maintained and
how data is exchanged as well as the Attribute Protocol used by BLE for data
structures.

## References ##

* [Bluetooth Core Specification](https://www.bluetooth.com/specifications/bluetooth-core-specification)
* [Bluetooth Assigned Numbers](https://www.bluetooth.com/specifications/assigned-numbers)
* [Introduction to Bluetooth Low Energy](https://learn.adafruit.com/introduction-to-bluetooth-low-energy/introduction) by Adafruit
* [Introduction to BLE](https://www.mikroe.com/blog/bluetooth-low-energy-part-1-introduction-ble) by Mikroe
* [Understanding Bluetooth Advertising Packets](https://j2abro.blogspot.com/2014/06/understanding-bluetooth-advertising.html)
* [A BLE Advertising Primer](http://www.argenox.com/a-ble-advertising-primer/)

### Footnotes ###

[^ble6a2]: Bluetooth Core Specification, Version 4.0, Volume 6, Part A,
    Section 2: Frequency Bands and Channel Arrangement

[^ble6b458]: Bluetooth Core Specification, Version 4.0, Volume 6, Part B,
    Section 4.5.8: Data Channel Index Selection

[^ble6b141]: Bluetooth Core Specification, Version 4.0, Volume 6, Part B,
    Section 1.4.1: Advertising and Data Channel Indexes

[^ble6b21]: Bluetooth Core Specification, Version 4.0, Volume 6, Part B,
    Section 2.1: Packet Format

[^ble6b23]: Bluetooth Core Specification, Version 4.0, Volume 6, Part B,
    Section 2.3: Advertising Channel PDU

[^ble6b233]: Bluetooth Core Specification, Version 4.0, Volume 6, Part B,
    Section 2.3.3: Initiating PDUs

[^ble6b212]: Bluetooth Core Specification, Version 4.0, Volume 6, Part B,
    Section 2.1.2: Access Address

[^ble6b13]: Bluetooth Core Specification, Version 4.0, Volume 6, Part B,
    Section 1.3: Device Address

[^ble3c222]: Bluetooth Core Specification, Version 4.0, Volume 3, Part C,
    Section 2.2.2: Roles when Operating over an LE Physical Channel

[^ble3c911]: Bluetooth Core Specification, Version 4.0, Volume 3, Part C,
    Section 9.1.1: Broadcast Mode and Observation Procedure

[^ble3c11]: Bluetooth Core Specification, Version 4.0, Volume 3, Part C,
    Section 11: Advertising and Scan Response Data Format
