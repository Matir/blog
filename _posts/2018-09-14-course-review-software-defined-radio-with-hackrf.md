---
layout: post
title: "Course Review: Software Defined Radio with HackRF"
category: Security
date: 2018-09-14
tags:
  - Security
  - Courses
  - SDR
  - HackRF
---

Over the past two days, I had the opportunity to attend Michael Ossman's course
"Software Defined Radio with HackRF" at [Toorcon XX](https://toorcon.org).  This
is a course I've wanted to take for several years, and I'm extremely happy that
I finally had the chance.  I wanted to write up a short review for others
considering taking the course.

## Course Material ##

The material in the course focuses predominantly on the basics of Software
Defined Radio and Digital Signal Processing.  This includes the math necessary
to understand how the DSP handles the signal.  The math is presented in a
practical, rather than academic, way.  It's not a math class, but a review of
the necessary basics, mostly of complex mathematics and a bit of trigonometry.
(My high school teachers are now vindicated.  I did use that math again.)
You don't need the math background coming in, but you do need to be prepared to
think about math during the class.  Extracting meaningful information from the
ether is, it turns out, an exercise in mathematics.

There's a lot of discussions of frequencies, frequency mixers, and how
frequency, amplitude, and phase are related.  Also, despite more than 20 years
as an amateur radio operator, I finally understand dB properly.  It's possible
to understand reasonably without having to do logarithms:

- +3db = x2
- +10db = x10
- -3db = 1/2
- -10db = 1/10

In terms of DSP, he demonstrated extracting signals of interest, clock recovery,
and other techniques necessary for understanding digital signals.  It really
just scratches the surface, but is enough to get a basic signal understood.

From a security point of view, there was only a single system that we "attacked"
in the class.  I was hoping for a little bit more of this, but given the detail
in the other content, I am not disappointed.

Mike pointed out that the course primarily focuses on getting signals
from the air to a digital series of 0 an 1 bits, and then leaves the remainder
to tools like python for adding meaning and interpretation of the bits.  While I
understand this (and, admittedly, at that point it's similar to decoding an
unknown network protocol), I would still like to have gone into more detail.

## Course Style ##

At the very beginning of the course, Mike makes it clear that no two classes he
teaches are exactly the same.  He adapts the course to the experience and
background of each class, and that was very evident from our small group this
week.  With such a small class, it became more like a guided conversation than a
formal class.

Overall, the course was *very* interactive, with lots of student questions, as
well as "[Socratic Method](https://en.wikipedia.org/wiki/Socratic_method)"
questions from the instructor.  This was punctuated with a number of hands-on
exercises.  One of the best parts of the hands-on exercises is that Mike
provides a flash drive with a preconfigured Ubuntu Linux installation containing
all the tools that are needed for the course.  This allows students to boot into
a working environment, rather than having to play around with tool installation
or virtual machine settings.  (We were, in fact, warned that VMs often do not
play well with SDR, because the USB forwarding has overhead resulting in lost
samples.)

Mike made heavy use of the poster pad in the room, diagramming waveforms and
information about the processes involved in the SDR architecture and the DSP
done in the computer.  This works well because he customizes the diagrams to
explain each part and answer student questions.  It also feels much more
engaging than just pointing at slides.  In fact, the only thing displayed on the
projector is Mike's live screen from his laptop, displaying things like the work
he's doing in GNURadio Companion and other pieces of software.

If you have devices you're interested in studying, you should bring them along
with you.  If time permits, Mike tries to work these devices into the
analysis during the course.

## Tools Used ##

- [HackRF One](https://greatscottgadgets.com/hackrf/) (Received as part of the class)
- [GNURadio](https://www.gnuradio.org/)
- [Baudline](http://www.baudline.com/)
- [inspectrum](https://github.com/miek/inspectrum)

## Additional Resources ##

- [Practical Signal Processing](https://amzn.to/2MwwChc) by Mark Owen
- [Understanding Digital Signal Processing](https://amzn.to/2QqMDZ4) by Richard G. Lyons
- [GNURadio Guided Tutorials](https://wiki.gnuradio.org/index.php/Guided_Tutorials)

## Opinions & Conclusion ##

This was a great class that I really enjoyed.  However, I really wish there had
been more emphasis on how you decode and interpret the unknown signals, such as
discussion of common packet types over RF, any tools for signals analysis that
could be built either in Python or in GNURadio.  Perhaps he (or someone) could
offer an advanced class that focuses on the signal analysis, interpretation, and
"spoofing" portions of the problem of attacking RF-based systems.

If you're interested in doing assessments of physical devices, or into radio at
all, I highly recommend this course.  Mike obviously *really* knows the
material, and getting a HackRF One is a pretty nice bonus.  Watching the
[videos on his website](https://greatscottgadgets.com/sdr/) will help you
prepare for the math, but will also result int a good portion of the content
being duplicated in the course.  I'm not disappointed that I did that, and I
still feel that I more than made good use of the time in the course, but it is
something to be aware of.
