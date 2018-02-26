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

One mistake from the Bluetooth Classic era was clearly avoided by the BLE
authors: while Classic shipped with a custom cipher named E0, BLE chooses the
standard AES cipher instead.

## Link Layer Security ##

Link Layer Security in Blueooth Low Energy uses 128-bit
[AES-CCM](http://www.ietf.org/rfc/rfc3610.txt) to offer both confidentiality
(encryption) and integrity (authentication).  The Message Authentication Code is
transmitted in the 4 octet Message Integrity Field (MIC) within the Data Channel
PDU.

### Pairing ###

Pairing is **not** synonymous with connecting in Bluetooth LE.  Pairing is the
process by which two BLE devices generate shared key material for future use in
encrypted connections.  If you're familiar with old Bluetooth 2.0 BDR pairing
(typically, a hard-coded 4 digit PIN for most devices), these mechanisms are a
dramatic improvement.

There are two pairing models available: **LE Legacy**, structurally similar to
the Bluetooth Classic Secure Simple Pairing, and **LE Secure Connections**.
Secure Connections have only been available since the Bluetooth 4.2
specification, so older devices will only be able to use LE Legacy.[^ble51a54]

**LE Legacy** pairing supports three mechanisms:

* **Just Works** -- This is the fallback pairing mechanism, supported by all
  devices that support LE Legacy pairing.  The key exchange takes place without
  any mechanism that prevents against a man in the middle or otherwise
  guarantees authenticity.
* **Passkey Entry** -- This requires that one device have display capabilities
  and the other have input capabilities.  (Often the peripheral will have a
  display and the central device, a laptop or cell phone, will have the input
  cabilities.)  The device with the output will display a 6 digit number.  This
  6 digit number is entered into the other device to verify the authenticity.
* **Out of Band** -- An out of band mechanism (not over the BLE connection) is
  used to exchange key material.  This might be NFC, QR codes with a camera,
  other network connections (WiFi, ethernet) or any other mechanism supported by
  the two endpoints.

In LE Legacy mode, neither Just Works nor Passkey Entry provide any protection
against even a passive eavesdropper -- no Diffie Hellman exchange takes place,
so all of the necessary keying material is available over the air.

**LE Secure Connections** uses the association models from BR/EDR Secure
Connections, which includes the LE Legacy pairing mechanisms as well as:

* **Numeric Comparison** -- The two devices display a 6 digit number, and some
  input is requested (even a single button can work for this) to confirm that
  both numbers are the same.  This shows that no active MITM has taken place, as
  both sides have arrived at the same keying material.

Additionally, in LE Secure Connections, Just Works and Passkey Entry use a
Diffie Hellman key exchange to build the key material.  Consequently, a passive
eavesdropper cannot obtain the key material for the link.  Just Works still has
no way to verify the authenticity of the devices, so an active MITM can still
get in the middle of Just Works pairing.[^ble51a54]

### Enabling Encryption ###

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
an attacker injecting a packet remains at 2<sup>32</sup>, and removes any
possibility of brute force attacks on the relatively short MIC field.

The nonce for each message is based on an 8 octet IV that is set up for each
connection along with a 39 bit counter and a 1 bit direction flag (to avoid
duplicate nonce in each direction of the connection).

### Known Attacks ###

## GATT Security ##

## References ##

* [Bluetooth Core Specification](https://www.bluetooth.com/specifications/bluetooth-core-specification)
* [Bluetooth LE Security](https://www.bluetooth.com/~/media/files/specification/bluetooth-low-energy-security.ashx)
* [Cracking the Bluetooth PIN](http://www.eng.tau.ac.il/~yash/shaked-wool-mobisys05/)

### Footnotes ###

[^ble2h]: Bluetooth Core Specification, Version 4.0, Volume 2, Part H:
    BR/EDR Controller Volume: Security

[^ble6e]: Bluetooth Core Specification, Version 4.0, Volume 6, Part E:
    Low Energy Link Layer Security

[^ble51a54]: Bluetooth Core Specification, Version 5, Volume 1, Part A,
    Section 5.4: Security Overview: LE Security
