---
layout: post
title: "\"Entry-Level\" Security Jobs and Experience"
category: Security
date: 2018-08-27
tags:
  - Security
---

I've seen a lot of discussion of experience requirements and "entry-level"
positions in the security industry lately.
[/r/netsecstudents](https://www.reddit.com/r/netsecstudents) and
[/r/asknetsec](https://www.reddit.com/r/asknetsec) are full of threads
discussing this topic, and I heard it being discussed at both BSidesLV and DEF
CON this summer.  The usual complaint is something along the lines of "all the
positions want experience, so how am I supposed to get experience?"  I'm going
to take a stab at addressing this, and hope to at least provide some
understanding.

<!--more-->

### A Word on Posted Job Requirements ###

First off, let's take a look at posted job requirements.  When you see a job
listing on a career search site or on the company's own site, those are usually
written by someone in HR who took the requirements from the manager and is doing
their best to fill those requirements with the best possible candidate.  If
they're concerned that they might get too many applicants and want to narrow
down the field, one technique they'll use is to raise the bar somewhat.  In
other words, some experience requirements are artificial gatekeeping by HR.
Apply anyway.  Maybe you'll have some unique experience that catches their eye,
maybe they won't get as many applicants as they thought, maybe everyone with 5
years experience will laugh at their salary offers.

### Security as a Specialization ###

I know this will not be a popular opinion, but **most security roles are not
entry-level jobs**.  If you have come straight out of school, you are probably
not qualified for a lot of security roles.  This is because security work is
essentially a specialization of your previous work.  Much like a doctor may do
general surgery before specializing in cardiothoracics, or an airplane mechanic
may do basic repairs before rebuilding engines, understanding fundamentals is
key to success in security.

If you are going to work in network security (firewalls, access control, etc.),
you need to have a thorough understanding of the OSI model, VLANs, the concept
of "Layer 3 switches", and so much more.  One of the best ways to get that
understanding is to work as a network administrator beforehand.

As an application security engineer, you need an understanding of how software
is built, application frameworks, OS APIs, and the software development life
cycle.  Understanding how the design document you read translates to actual
software, or how the application stack in uses handles
authentication/authorization are critical for security reviews.

If you want to work in digital forensics & incident response, you need to
understand how the operating systems involve work, where the artifacts you're
pulling from come from, how to find additional artifacts, and many other things.

In penetration testing, you need familiarity with a variety of operating
systems, as most networks are a heterogenous mixture, as well as basic concepts
of networking and application security.  A basic understanding of the controls
involved in securing the systems is also important for effective penetration
testing (how can you test security controls you don't understand?).

The biggest problem in security is that there are so many unknowns.  Worst, of
course, are the unknown unknowns -- the things you don't know that you don't
know.  Having experience in these areas reduces (but does not eliminate, of
course) these unknown unknowns.

Software engineers, developers, network administrators, etc., all depend on
abstractions across the layers of computing.  Part of working in security is about understanding
where those abstractions break down, and it's critical that security
practitioners understand what those abstractions are and how they interact.
Experience working with those technologies helps the practitioner understand the
abstractions.

### Getting Security Experience ###

There are a number of roles that can help gain relevant work experience:

- IT Help Desk (Yes, it's thankless, but it's good exposure to a range of
  IT systems.)
- System administrator (obviously a lot of understanding of how systems
  interact, how operating systems work, shell experience, etc.)
- Network administrator (understand network ACLs, VLANs, network appliances)

All of this is not to say that formal work experience is the only way to gain
relevant experience.  There are many ways to develop technical experience.
Fortunately, many of the relevant tools are open source or have community
editions that are available.

I've [written before about building a
homelab](https://systemoverlord.com/2017/10/24/building-a-home-lab-for-offensive-security-basics.html)
for Offensive Security, but there's many different approaches.  There are
online courses in this area:

- [Penetrating Test with Kali
  Linux](https://www.offensive-security.com/information-security-training/penetration-testing-training-kali-linux/)
- [Pentester Academy](https://www.pentesteracademy.com/)
- [eLearnSecurity](https://www.elearnsecurity.com/course/penetration_testing/)

Alternatively, you can take more of the self-taught approach with options like
CTFs or [HackTheBox.eu](https://hackthebox.eu).  There's a number of different
approaches.

Of course, if you're still a student, there are *internships* to help you gain
experience.  I've now hosted (managed) 4 interns in security, and those have
been a good way to gain experience and a better understanding of the industry.
Some have worked out, some haven't, but I'd like to think they've all learned
something along the way.

If you don't have much experience, find a way to work your lab or
extracurricular studies into your resume.  Place it under education, and list
the things you've learned how to do.  Don't try to pretend that it's industry
experience, but show that you're driven, that you've learned things, and that
you can execute.  In fact, having personal research/lab/etc., shows that you're
capable of getting things done on your own without individual supervision, which
is a highly desirable trait.

### Entry Level Positions in Security ###

Perhaps you *really* want to start off in security.  There *are* positions, but
they will be harder to find and might not be the position you think.  Many of
these positions involve very tool-specific or operational workflows and can be
repetitive, but may offer a good learning and growth opportunity.

For example:

- Tier 1 SOC
- Some roles in a Managed Security Provider (MSP)
- Vulnerability Management Engineer (Mostly scanning/patching)

### Conclusion ###

Look, I know it's not what everyone wants to hear (especially those with little
experience) but it is what I see in the current industry.  Understanding how
security fits into the bigger picture makes the most effective security
practitioner, and that comes from experience.  Obviously, industry experience
will please the HR and recruiters, but showing the experience you do have (and
building your experience) will help you get the opportunities you want.
