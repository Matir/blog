---
layout: post
title: "Course Review: Reverse Engineering with Ghidra"
category: Security
date: 2020-10-17
tags:
  - Reverse Engineering
  - Course Review
excerpt:
    Last week, I took the "[Reverse Engineering with
    Ghidra](http://infiltratecon.com/conference/training/reverse-engineering-with-ghidra.html)"
    taught by [Jeremy Blackthorne (0xJeremy)](https://twitter.com/0xjeremy) of the
    [Boston Cybernetics Institute](https://www.bostoncybernetics.org/).  It was
    a high-quality experience and well worth the time, and I can highly
    recommend this course.  Check out the full review.
---

If you're a prior reader of the blog, you probably know that when I have the
opportunity to take a training class, I like to write a review of the course.
It's often hard to find public feedback on trainings, which feels frustrating
when you're spending thousands of dollars on that course.

Last week, I took the "[Reverse Engineering with
Ghidra](http://infiltratecon.com/conference/training/reverse-engineering-with-ghidra.html)"
taught by [Jeremy Blackthorne (0xJeremy)](https://twitter.com/0xjeremy) of the
[Boston Cybernetics Institute](https://www.bostoncybernetics.org/).  It was
ostensibly offered as part of the Infiltrate Conference, but 20202 being what it
is, there was no conference and it was just an online training.  Unfortunately
for me, it was being run on East Coast time and I'm on the West Coast, so I got
to enjoy some *early* mornings.

I won't bury the lede here -- on the whole, the course was a high-quality
experience taught by an instructor who is clearly both passionate and
experienced with technical instruction.  I would highly recommend this course if
you have little experience in reverse engineering and want to get bootstrapped
on performing reversing with Ghidra.  You absolutely do need to have some
understanding of how programs work -- memory sections, control flow, how data
and code is represented in memory, etc., but you don't need to have any
meaningful RE experience.  (At least, that's my takeaway, see the course
syllabus for more details.)

I would say that about 75% of the total time was spent executing labs and the
other 25% was spent with lecture.  The lecture time, however, had very little
prepared material to read -- most of it was live demonstration of the toolset,
which made for a great experience when he would answer questions by showing you
exactly how to get something done in Ghidra.

Like many information security courses, they provide a virtual machine image
with all of the software installed and configured.  Interestingly, they seem to
share this image across multiple courses, so the actual exercises are downloaded
by the student during the course.  They provide both VirtualBox and VMWare VMs,
but both are OVAs which should be importable into either virtualization
platform.  Because I always need to make things harder on myself, I actually
used QEMU/KVM virtualization for the course, and it worked just fine as well.

The coverage of Ghidra as a tool for reversing was excellent.  The majority of
the time was spent on manual analysis tasks with examples in a variety of
architectures.  I believe we saw X86, AMD64, MIPS, ARM, and PowerPC throughout
the course.  Most of the reversing tasks were a sort of "crack me" style
challenge, which was a fitting way to introduce the Ghidra toolkit.

We also spent some time on two separate aspects of Ghidra programming --
extending Ghidra with scripts, plugins, and tools, and headless analysis of
programs using the GhidraScript API.  Though Ghidra is a Java program, it has
both Java APIs and Jython bindings to those APIs, and all of the headless
analysis exercises were done in Python (Jython).

Jeremy did a great job of explaining the material and was very clear in his
teaching style.  He provided support for students who were having issues without
disrupting the flow for other students.  One interesting approach is encouraging
students to just keep going through the labs when they finish one, rather than
waiting for that lab to be introduced.  This ensures that nobody is sitting idle
waiting for the course to move forward, and provides students the opportunity to
learn and discover the tools on their own before the in-course coverage.

One key feature of Jeremy's teaching approach is the extensive use of
[Jupyter](https://jupyter.org/) notebooks for the lab exercises.  This
encourages students to produce a log of their work, as you can directly embed
shell commands and python scripts (along with their output) as well as Markdown
that can include images or other resources.  A sort of a hidden gem of his
approach was also an introduction to the
[Flameshot](https://flameshot.js.org/#/) screenshot tool.  This tool lets you
add boxes, arrows, highlights, redactions, etc., to your screenshot directly in
an on-screen overlay.  I hadn't seen it before, but I think it'll be my goto
screenshot tool in the future.

Other tooling used for making this a remote course included a Zoom meeting for
the main lecture and a Discord channel for class discussion.  Exercises and
materials were shared via a Sharepoint server.  Zoom was
particularly nice because Jeremy recorded his end of the call and uploaded the
recordings to the Sharepoint server, so if you wanted to revisit anything, you
had both the lecture notes *and* video.  (This is important since so much of the
class was done as live demo instead of slides/text.)

It's also worth noting that it was clear that Jeremy adjusted the course
contents and pace to match the students goals and pace.  At the beginning, he
asked each student about their background and what they hoped to get out of the
course, and he would regularly ask us to privately message him with what
exercise we're currently working on (the remote version of the instructor
walking around the room) to get a sense of the pace.  BCI clearly has more
exercises than can fit in the four day timing of the course, so Jeremy selected
the ones most relevant to student's goals, but then provided *all* the materials
at the end of the course so we could go forth and learn more on our own time.
This was a really nice element to help get the most out of the course.

The combination of the live demo lecture style, lots of lab/hands-on exercises,
and customized content and pace really worked well for me.  I feel like I got a
lot out of the course and am at least somewhat comfortable using Ghidra now.
Overall, definitely a recommendation for those newer to reverse engineering or
looking to use Ghidra for the first time.

I also recently purchased [The Ghidra Book](https://amzn.to/3m3skjh) so I
thought I'd make a quick comparison.  The Ghidra Book looks like good reference
material, but not a way to learn from first principles.  If you haven't used
Ghidra at all, taking a course will be a much better way to get up to speed.
