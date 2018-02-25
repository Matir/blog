---
layout: post
title: "Bluetooth LE for Hackers: Security"
category: Security
series: "Bluetooth LE for Hackers"
tags:
  - Security
  - Bluetooth LE
kramdown: true
---

So far in this series, there hasn't been a lot of discussion of the security of
Bluetooth Low Energy, and that's been for several good reasons: the fundamentals
are important to understanding what's going on, I wanted to collect all the BLE
security features in one place (that's this post), and quite frankly: BLE
doesn't have nearly the complicated security story that Bluetooth Classic does.
Even though Bluetooth Low Energy does provide a number of security features,
most devices that I've seen don't actually use them, and those that don't often
don't use them correctly or use them in insecure ways.

<!--more-->

* TOC
{:toc}

## Security Overview ##

While BR/EDR (Bluetooth Classic) devices get more than 30 pages in the part of
the volume defining the controller behavior devoted to security[^ble2h], the Low
Energy Controller volume spends 4 pages on security[^ble6e].  This is not,
however, the only security controls in Bluetooth Low Energy.  While the Link
Layer has encryption and authentication, the GATT layer adds additional security
controls of its own.  However, the overall security story remains relatively
simple.

## Link Layer Security ##

Link Layer Security in Blueooth Low Energy uses 128-bit
[AES-CCM](http://www.ietf.org/rfc/rfc3610.txt) to offer both confidentiality
(encryption) and integrity (authentication).  The Message Authentication Code is
transmitted in the 4 octet Message Integrity Field (MIC) within the Data Channel
PDU.

To enable encryption, Link Layer Control Protocol PDUs (LLCP) (described in the
[prior post](NOPUBLISH)) are used.  The central device initiates encryption by
sending an `LL_ENC_REQ` PDU to the peripheral device.  This is used to request
encryption parameters to be setup, and receives an `LL_ENC_RSP` packet is
response from the peripheral.  Once keys have been established, a
`LL_START_ENC_REQ` requests switching to encryption, followed by
`LL_START_ENC_RSP` to finish the switch.

Not all devices support encryption -- when it is not supported, the peripheral
will send a `LL_REJECT_IND` PDU to inform the central device that encryption is
not available.  The devices may then continue unencrypted, or the central device
might choose to terminate the connection.

In the event of a bad authentication on a packet, the host treats the connection
as lost and returns to the standby state.  This ensures that the probability of
an attacker injecting a packet remains at 2^32^, and removes any possibility of
brute force attacks on the relatively short MIC field.

The nonce for each message is based on an 8 octet IV that is set up for each
connection along with a 39 bit counter and a 1 bit direction flag (to avoid
duplicate nonce in each direction of the connection).

## References ##

### Footnotes ###

[^ble2h]: Bluetooth Core Specification, Version 4.0, Volume 2, Part H:
    BR/EDR Controller Volume: Security

[^ble6e]: Bluetooth Core Specification, Version 4.0, Volume 6, Part E:
    Low Energy Link Layer Security
