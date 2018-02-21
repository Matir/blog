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
protocol layer.  The peripheral typically becomes the server, and the central
device becomes the client.  Most data exchange takes place in the form of
requests from the client to the server to either write or read values stored as
**attributes** on the server.  The exception is notifications, which are used by
a peripheral to notify the central device of changes in state.

## The Attribute Protocol ##

The Attribute Protocol (ATT) is the building block of all data exchange between
Bluetooth Low Energy devices.  ATT defines attributes, which represent the wire
format for data exchange between BLE devices.  Each attribute consists of three
elements:

* A handle (2 octets)
* A UUID (2 or 16 octets)
* A value (arbitrary length)

Standard attributes have 16-bit reserved UUIDs assigned by the Bluetooth SIG,
which provides a [document of assigned UUIDs](NOPUBLISH).  Custom attributes use
128 bit UUIDs assigned by the manufacturer of the device (and consequently, the
other endpoint of the connection would also need to be familiar with meaning of
that UUID).

## References ##

* [Bluetooth: ATT and GATT](https://epxx.co/artigos/bluetooth_gatt.html)

### Footnotes ###
