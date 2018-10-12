---
layout: post
title: "Hardware Hacking, Reversing and Instrumentation: A Review"
category: Security
date: 2017-11-11
tags:
  - Security
  - Training
  - Electronics
  - Hardware Hacking
  - Course Review
---

I recently attended [Dr. Dmitry Nedospasov](https://toothless.co)'s 4-day
["Hardware Hacking, Reversing and
Instrumentation"](https://toothless.co/trainings/) training class as part of the
[HardwareSecurity.training](https://hardwaresecurity.training) event in San
Francisco.  I learned a lot, and it was incredibly fun class.  If you understand
the basics of hardware security and want to take it to the next level, this is
the course for you.

The class predominantly focuses on the use of
[FPGAs](https://en.wikipedia.org/wiki/Field-programmable_gate_array) for
breaking security in hardware devices (embedded devices, microcontrollers,
etc.).  The advantage of FPGAs is that they can be used to implement arbitrary
protocols and can operate with very high timing resolution.  (e.g., single clock
cycle, since it's essentially synthesized hardware.)

The particular FPGA board used in this class is the
[Digilent Arty](http://store.digilentinc.com/arty-a7-artix-7-fpga-development-board-for-makers-and-hobbyists/),
based on the
[Xilinx Artix 7 FPGA](https://www.xilinx.com/products/silicon-devices/fpga/artix-7.html).
This board is clocked at 100 MHz, allowing 10ns resolution for high-speed
protocols, timing attacks, etc.  The development board contains over 33,000
logic cells with more than 20,000 LUTs and 40,000 flip-flops.  (And if you don't
know what those things are, don't worry, it's explained in the class!)  The
largest project in the class only uses about 1% of the resources of this FPGA,
so there's plenty for more complex operations after the class.

Dmitry is obviously very knowledgable as an instructor and has a very direct and
hands-on style.  If you're looking for someone to spoon feed you the course
material, this won't be the course you're looking for.  If, on the other hand,
you prefer to learn by *doing* and just need an instructor to get you started
and help you if you have issues, Dmitry has the perfect teaching style for you.

You should have some knowledge of basic hardware topics before starting the
class.  Knowing basic logic gates (AND, OR, NAND, XOR, etc.), basic electronics
(i.e., how to supply power and avoid short circuits), and being familiar with
concepts like JTAG and UARTs will help.  I've taken several other hardware
security classes before (including with Joe Fitzpatrick, another of the
HardwareSecurity.training instructors and organizers) and I found that
background knowledge quite useful.  If you don't know the basics, I highly
reccommend taking a course like Joe's "Applied Physical Attacks on Embedded
Systems and IoT" first.

The first day of the class is mostly lecture about the architecture of FPGAs and
basic Verilog.  Some Verilog is written and results simulated in the Xilinx
Vivado tool.  Beginning with the second day, work moves to the actual FPGA,
beginning with a task as "simple" as implementing a UART in hardware, then
moving to using the FPGA to brute force a PIN on a microcontroller, and finally
moving on to a timing attack against the microcontroller.  Many of the projects
are implemented with the performance-critical parts done in Verilog on the FPGA
and then communicating with a Python script for logic & calculation.

I really enjoyed the course -- it was challenging, but not defeatingly so, and I
learned quite a few new things from it.  This was my first exposure to FPGAs and
Verilog, but I now feel I could successfully use an FPGA for a variety of
projects, and look forward to finding something interesting to try with it.
