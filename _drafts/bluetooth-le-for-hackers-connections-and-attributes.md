---
layout: post
title: "Bluetooth LE for Hackers: Connections and Attributes"
category: Security
tags:
  - Bluetooth LE
  - Security
series: "Bluetooth LE for Hackers"
---

In this installment in the Bluetooth LE for Hackers series, I'll cover what
happens once a connection is established and how data is structured in a
Bluetooth LE connection.  Bluetooth LE connections exchange data via Generic
Attribute Profiles (GATT), which are built on top of the Attribute Protocol
(ATT).  If you need a refresher on how devices advertise, are discovered, and
connections are established, see the [Basic Concepts post](NOPUBLISH) in this series.

<!--more-->

* TOC
{:toc}

## Connection High Level Overview ##

Bluetooth Low Energy connections are always between exactly two devices.  At the
link layer, this is defined as the central device (initiates the connection to
an advertising device) and the peripheral device (the device receiving the
connection).  When devices are connected, Bluetooth Low Energy defines a
Client/Server architecture between the two devices in a connection for the
protocol layer.[^ble3f2]  The peripheral typically becomes the server, and the
central device becomes the client.  Most data exchange takes place in the form
of requests from the client to the server to either write or read values stored
as **attributes** on the server.  The exception is notifications, which are used
by a peripheral to notify the central device of changes in state.

## Data Channel PDUs ##

Once a connection has been established with the `CONNECT_REQ` advertising PDU
and communications have moved to the data channels, the peripheral and central
device begin to exchange Data Channel PDUs encapsulated in the same Link Layer
packets as advertising packets.

The Data Channel PDUs have a 2 octet header, a variable length payload, and an
optional 4 octet message integrity check, depending on security
settings.[^ble6b24]  The
PDU has a length from 2 octets to 34 octets, though since Bluetooth 4.2, the
endpoints have been able to negotiate PDU lengths up to 257 octets.[^ble56b4510]

![Data PDU](/img/blog/ble/data_pdu.svg)

### Data PDU Header ###

The header contains a variety of fields, even in just two octets:

* Link Layer Data PDU Type (LLID, 2 bits) -- Identifies the type of PDU.  Values
  include:[^ble6b24]
  * `00b` - Reserved
  * `01b` - Continuation PDU
  * `10b` - Data PDU
  * `11b` - Control PDU
* Next Expected Sequence Number (NESN, 1 bit) -- Used for acknowledgement and
  flow control.[^ble6b459]
* Sequence Number (SN, 1 bit) -- Also used for acknowledgement and flow
  control.[^ble6b459]
* More Data (MD, 1 bit) -- Indicates that the sender of this PDU has more data
  to send and the connection should remain open.[^ble6b456]
* Reserved (3 bits)
* Length (5 bits, 8 bits since 4.2) -- Length of the payload (and MIC, if
  present), in octets.[^ble6b24]
* Reserved (3 bits, removed in 4.2 to expand length)

![Data PDU Header](/img/blog/ble/data_pdu_header.svg)

### Control PDUs ###

Control PDUs request a variety of operations to have the devices change
how the Link Layer operates on this connection.  The operations include changing
connection parameters established in the `CONNECT_REQ`, updating the channel map
for usable channels, terminate the connection, establish an encrypted link
(details on encrypted links will be in the BLE security post), and the ability
to reject any of these requests.[^ble6b24]  Since 4.2, this also includes the
ability to negotiate longer PDU MTUs.[^ble56b24]

### L2CAP Data ###

Data PDUs use Logical Link Control and Adaptation Layer Protocol (L2CAP) to
manage data flowing between endpoints.  L2CAP performs
fragmentation and recombination of messages that are too large to fit in a
single PDU (remember, there's only 32 octets for data prior to 4.2).

The design of L2CAP is highly flexible because it is used in both Bluetooth
Classic (BR and EDR) as well as Bluetooth LE.  Many of L2CAP's features are not
used in Bluetooth LE implementations.  Only the Attribute Protocol, Security
Manager Protocol, and L2CAP signaling are supported over L2CAP on Bluetooth LE.

L2CAP is essentially just a single header before the Attribute Protocol data is
sent.  Only the first packet of a multiple-packet transfer contains the L2CAP
header, and has the LLID `10b`.  Continuations do not contain the L2CAP header,
leaving more space for data, and these packets have LLID `01b`.  The contents of
an L2CAP message is called a Service Data Unit (SDU).

The L2CAP header is 32 bits, with 16 bits each for a length field and a channel
ID, represented in little endian form.  In Bluetooth LE, the channel ID is one
of 3 options to indicate which protocol is contained in the Service Data Unit.
(Attribute Protocol, Security Manager Protocol, and L2CAP Signaling).  The
length is the length of the SDU in octets, and can be up to 65535.[^ble3a31]

## The Attribute Protocol (ATT) ##

The Attribute Protocol (ATT) is the building block of all data exchange between
Bluetooth Low Energy devices.  ATT defines attributes, which represent the wire
format for data exchange between BLE devices.  Each attribute consists of three
elements:

* A handle (2 octets)
* A UUID (2 or 16 octets)
* A value (arbitrary length)

The UUID is used to provide a definition and context for the attribute -- in
other words, the type of the value.[^ble3f2]  Standard attributes have 16-bit
reserved UUIDs assigned by the Bluetooth SIG (in the higher-layer profiles used
on top of the Attribute Protocol).  Custom attributes use 128 bit UUIDs assigned
by the manufacturer of the device (and consequently, the other endpoint of the
connection would also need to be familiar with the meaning of that UUID).  All
16 bit registered UUIDs can be expanded to their 128 bit form with the following
template:[^ble3f32]

    0000xxxx-0000-1000-8000-00805F9B34FB

The handle value is assigned on each device to uniquely identify an *instance*
of an attribute, as each device may potentially have multiple instances of
attributes with the same UUID.  Handles are used to refer to a single attribute
instance stored on an attribute server.  No two attributes (regardless of type)
will have the same handle on a device.[^ble3f32]

Note also that the value length is not transferred as part of the Attribute
Protocol.  Since the Attribute Protocol is designed to be encapsulated in
another protocol, it is expected that the recipient infers the value length from
the higher level protocol, though the Attribute Protocol specifies an upper
bound of 512 octets.[^ble3f329]

Attribute Protocol PDUs (sent as an L2CAP SDU) start with a 1-octet opcode that
indicates the operation to be performed.  The supported operations are:

* Request -- PDU sent to client, expecting response.
* Response -- PDU sent client to server in response to a request.
* Command -- PDU sent client to server, no response required.
* Notification -- Unsolicited PDU from client to server, no confirmation
  required.
* Indication -- Unsolicited PDU from client to server, confirmation required.
* Confirmation -- Confirms receipt of an indication.

<!-- TODO: More detail on Attribute Operations? -->

## The Generic Attribute Profiles (GATT) ##

The Generic Attribute Profiles (GATT) provide a way of structuring Attributes to
provide meaningful services between clients and servers.  Recall that Attributes
consist of a 2 octet handle, an attribute type represented as a UUID, and a
value.  Handles are expected to be static for a given server and should not
change over time.  (In practice, you will find that each model of device has
handles that remain largely unchanged over time or over different units of the
same device, as the handles are generally allocated in a deterministic manner in
the firmware.)[^ble3g25]

### The Use of Attributes in GATT ###

Short form GATT UUIDs (16-bit values) are assigned by the Bluetooth SIG which
provides lists of short UUIDs used for
[services](https://www.bluetooth.com/specifications/gatt/services) and
[characteristics](https://www.bluetooth.com/specifications/gatt/characteristics).
Longer UUIDs are to be randomly generated by the implementer and should not use
the Bluetooth SIG UUID space defined in the attribute protocol.

Attributes may contain permission bits defined by the higher layer protocols,
including GATT.  This can include restrictions on reading/writing, and the
available permissions are defined for each attribute type.  The permission bits
are stored as part of the attribute value (since they are defined by the
higher layer protocols storing data as attributes) and are not sent as part of
the wire format of attributes sent over the air.[^ble3g25]

The ordering of handles is used to arrange attributes into logical groupings.
After a declaration attribute that defines a new grouping (either a service
or a characteristic), all additional attributes are part of that grouping until
the next "cornerstone" attribute defining a new service or characteristic.

### Services ###

Services are the highest level grouping of attributes, and are logically a
collection of data to implement a particular behavior.  A service needs one or
more chracteristics to implement the service and is for the device to perform a
particular function.  All attributes are either a service definition or exist
within a service definition.

An attribute with an Attribute type of the UUID `0x2800` defines a new Primary
Service, while `0x2801` is used for Secondary Services.  (In practice, secondary
services are rarely used, and all devices must have at least one primary
service.)  The value field contains another UUID, which is used to identify the
service.[^ble3g31]  Service definitions are always read only.  Public services,
defined by the Bluetooth SIG, have [16-bit UUIDs
assigned](https://www.bluetooth.com/specifications/gatt/services) and have a
particular set of characteristics required for their implementations.  Private
services should use random UUIDs.  A service definition continues until the next
service definition, or the end of the attributes on the device.  A device may
have more than one service with the same UUID.

Examples of some common services include:

* [Battery Level](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.battery_service.xml)
* [Device Information](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.device_information.xml)
* [Human Interface Device](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.human_interface_device.xml)

### Characteristics ###

Characteristics are the next level of grouping within services.  Each
characteristic begins with an attribute of type `0x2803` and continues until the
next characteristic declaration attribute or service declaration attribute.  The
value of the characteristic declaration attribute is a structure containing
properties (1 octet), the characteristic value attribute handle (2
octets) and the UUID of the characteristic (2 or 16 octets).  A single service
may have more than one characteristic with the same UUID.[^ble3g33]

Like other UUIDs, 16 bit values are assigned by the Bluetooth SIG, which
maintains a [list of defined
characteristics](https://www.bluetooth.com/specifications/gatt/characteristics).
Some common examples of characteristics include:

* Alert Status
* Appearance
* Last Name
* Email Address
* Serial Number String
* String
* URI

The characteristic properties are a bitfield that define which standard
read/write/notify/indicate operations are supported on the characteristic.

The first attribute after the characteristic declaration contains the
characteristic value.  It has the handle that was specified in the
characteristic value attribute handle in the declaration's value field.
Likewise, it has the UUID specified in the characteristic declaration.  The
value of this attribute is the value of the characteristic.[^ble3g332]

Characteristics may include optional descriptor declarations that provide
additional metadata about the particular characteristic.  These can include a
human-readable description of the characteristic (UUID `0x2901`) or metadata,
such as indicating that a temperature value is measured in degrees Celsius.

### GATT Structure Example ###

This is an exemplar structure for a hypothetical Bluetooth Low Energy device to
explain the relationship between Attributes, Services, and Characteristics.

![GATT Attribute Structure](/img/blog/ble/gatt_attributes.svg)

This shows a device that implements two services, each with one characteristic.
The structure of the device is as follows:

* Primary Service (Handle `0x0001`, UUID `0x2800`, Value `0x180F`): Battery Status Service defined by Bluetooth SIG)
  * Characteristic Declaration (Handle `0x0002`, UUID `0x2803`, Properties
    `0xA`, Value Handle `0x0003`, Value UUID `0x2A19`)
    * Characteristic Value (Handle `0x0003`, UUID `0x2A19`, Value `0x64`):
      Battery Level 100%
* Primary Service (Handle `0x0005`, UUID `0x2800`, Value
  `7f9eb1be-51ea-4c9e-bd0e-2234b6527d00`): Custom Primary Service
  * Characteristic Declaration (Handle `0x0006`, UUID `0x2803`, Properties
    `0xA`, Value Handle `0x0007`, Value UUID `0x2A3D`)
    * Characteristic Value (Handle `0x0007`, UUID `0x2A3D`): String "Hello
      World"

## References ##

* [Bluetooth Core Specification](https://www.bluetooth.com/specifications/bluetooth-core-specification)
* [Bluetooth Assigned Numbers: GATT Services](https://www.bluetooth.com/specifications/gatt/services)
* [Bluetooth Assigned Numbers: GATT Characteristics](https://www.bluetooth.com/specifications/gatt/characteristics)
* [Bluetooth: ATT and GATT](https://epxx.co/artigos/bluetooth_gatt.html)
* [Logical Link Control and Adaptation Layer Protocol](http://dev.ti.com/tirex/content/simplelink_cc2640r2_sdk_1_35_00_33/docs/ble5stack/ble_user_guide/html/ble-stack/l2cap.html) on TI Developer Guide

### Footnotes ###

[^ble6b24]: Bluetooth Core Specification, Version 4.0, Volume 6, Part B,
    Section 2.4: Data Channel PDU

[^ble6b456]: Bluetooth Core Specification, Version 4.0, Volume 6, Part B,
    Section 4.5.6: Closing Connection Events

[^ble6b459]: Bluetooth Core Specification, Version 4.0, Volume 6, Part B,
    Section 4.5.9: Acknowledgement and Flow Control

[^ble56b4510]: Bluetooth Core Specification, Version 5.0, Volume 6, Part B,
    Section 4.5.10: Data PDU Length Management

[^ble6b242]: Bluetooth Core Specification, Version 4.0, Volume 6, Part B,
    Section 2.4.2: LL Control PDU

[^ble56b242]: Bluetooth Core Specification, Version 5.0, Volume 6, Part B,
    Section 2.4.2: LL Control PDU

[^ble3a31]: Bluetooth Core Specification, Version 4.0, Volume 3, Part A,
    Section 3.1: Data Packet Format

[^ble3f2]: Bluetooth Core Specification, Version 4.0, Volume 3, Part F,
    Section 2: Protocol Overview

[^ble3f32]: Bluetooth Core Specification, Version 4.0, Volume 3, Part F,
    Section 3.2: Attribute Protocol: Basic Concepts

[^ble3f329]: Bluetooth Core Specification, Version 4.0, Volume 3, Part F,
    Section 3.2.9: Long Attribute Values

[^ble3g25]: Bluetooth Core Specification, Version 4.0, Volume 3, Part G,
    Section 2.5: Attribute Protocol

[^ble3g31]: Bluetooth Core Specification, Version 4.0, Volume 3, Part G,
    Section 3.1: Service Definition

[^ble3g33]: Bluetooth Core Specification, Version 4.0, Volume 3, Part G,
    Section 3.3: Characteristic Definition

[^ble3g332]: Bluetooth Core Specification, Version 4.0, Volume 3, Part G,
    Section 3.3.2: Characteristic Value Declaration
