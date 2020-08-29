---
layout: post
title: "Certifications Aren't as Big a Deal as You Think"
category: Security
tags:
  - Security
  - Industry
  - Training
date: 2019-03-15
---
For some reason, security certifications get discussed a lot, particularly in
forums catering to those newer to the industry.  (See, for example,
[/r/asknetsec](https://reddit.com/r/asknetsec).)  Now I'm not talking about
business certifications (ISO, etc.) but personal certifications that allegedly
demonstrate some kind of skill on behalf of the individual.  There seems to be a
lot of focus on certifications that you "need" or that will land you your dream
security job.

I'm going to make the claim that you should stop worrying about certifications
and instead spend your time learning things that will help you in the real
world -- or better yet, actually applying your skills in the real world.  There
are likely some people who will strongly disagree with me, and that's good, but
I want it to be a discussion that people think about, instead of just assuming
certifications are some kind of magic wand.

<!--more-->

I don't think certifications are bad -- in fact, I've got a few myself.  I'm a
current holder of both the OSCP and OSCE from [Offensive
Security](https://offensivesecurity.com) (back when you could get an OSCP *and*
take the exam naked if you wanted) and I've formerly held RHCE, LPIC-1 and
LPIC-2 and a handful of other minor certifications.  In fact, I'm damn proud of
all of them.

I've been employed in the tech industry for over a decade, more than half of
which has been doing security work.  I've had the privilege (and
responsibility) of interviewing a couple hundred people for tech roles in that
time.  I write this not for the ego boost, but in order to provide context for
my viewpoint.  One important note is that more than 7 years of that experience
is with a single employer, which will obviously influence my thinking on this
subject.  It's also important to note that this post (like others on my blog) is
**written in my personal capacity and does not necessarily represent the
viewpoint or hiring practices of any employer, past, present, or future.**

Most roles in infosec require a wide range of knowledge and the understanding of
how to apply that knowledge.  There are many skillsets necessary beyond what can be taught
in a short class for a certification.  For example, none of the technical
certifications spend any significant time on soft skills, but the good
practitioners in our industry are excellent communicators and can at least
understand the business priorities, even if they don't necessarily agree with
them.

### OSCP ###

OSCP is probably the most frequently-discussed certification I've seen.  There's
a reason for its popularity -- it is definitely high quality, and it has an exam
that requires application of knowledge rather than mere repetition.  The course
developers (Offensive Security) know their material well, and holding the
certification definitely has value.  However, there's a big gap between OSCP and
being a real-world penetration tester:

- Every box in the OSCP labs and exam is definitely vulnerable in some way.
  This is not necessarily true in the real world.
- OSCP focuses almost entirely on commercial off-the-shelf (COTS) software, but
  nearly every significant enterprise will have some amount of custom software.
- The OSCP scope can best be described as "come at me, bro", but real world
  penetration tests have vastly different scope.
- Even though OSCP requires you to do a report for the exam, report-writing and
  communicating findings to the customer is a skill that is not adequately
  taught or tested.

When I did OSCP, I did it to learn about environments I hadn't yet been exposed
to, and I did it to prove to myself that it was something I could do.  My
employer didn't need me to have it, and I haven't used it to leverage my way
into a new job.  I did PWK/OSCP because I believed it would (and it did) make me
more effective and enriched my skill set.  (In case you're wondering, the single
biggest thing I learned from OSCP was how to effectively keep notes and organize
information during a large-scale penetration test.)

### OSCE ###

I also hold the OSCE certification, which I like to think of as the "big
brother" to OSCP.  Rather than focusing on penetration testing at a large
network scale, this is exploitation at the individual service/server scale.
Like OSCP, it requires application of skills on the exam.  Again, I took the
course and exam in order to learn new things (more about exploiting Windows) and
to prove to myself that I could.  Honestly, if I were to do it over again, I'd
probably choose to take some of the CoreLan training instead -- you won't get a
fancy certification, but I understand they go into far more detail and seem to
have done a better job of keeping the training up to date with new versions of
Windows.

### Security+ ###

Security+ is a common certification when you're first getting started.  It's
useful to get past the HR drone to an interview, but I'm not convinced the
knowledge gained during it is enough to be a practical use case.  If you want to
get it quickly, I suggest using a service like
[Certblaster](https://shareasale.com/r.cfm?b=1254228&u=2497236&m=63545&urllink=&afftrack=)
with interactive practice tests.

### CISSP ###

CISSP is a strange certification to me.  It seems to be one of the
certifications that people get because they work for a consultancy that wants to
be able to say "all of our pentesters are CISSP certified."  So, if you want to
work in consulting, and you have the relevant industry experience for CISSP, go
for it.  Better yet, convince your employer to pay for it.  (It's not cheap for
a multiple-choice test.)

The material is not bad, but like all of the multiple-choice style exams, it's
all about memorizing and regurgitating basic information, and not about the
application of that information in a real-world environment.  Additionally, a
lot of the information is policy-oriented, so depending on your ideal role, you
might find some of it useful.

I know a lot of people working on internal teams that let their CISSP lapse just
because there's not much value in it there (and you have to pay to keep it
current).

### GIAC Certs ###

The GIAC certifications that go with SANS classes are, like so many others,
purely multiple choice exams.  Consequently, they do a poor job of showing
application of technical skills.  On the other hand, the courses associated with
the exams are of decent quality and are very consistently taught.  These
certifications are also widely known, so are good choices for those who have to
sell themselves to customers (e.g., consulting).

### What not to do ###

Like everything else on your resume, do not lie about your certifications.  For
one, most of them are easily checked.  Far more importantly, don't list any
certification you're not prepared to discusss in an interview.  I've had far too
many candidates respond with "oh, I did that a few years ago and I don't
remember" when asked about a certification.  If you can't use the information
today, then claiming it makes you a better candidate for the job is a lie.  It's
approximately like trying to get a job that involves driving a truck when you
haven't driven in 5 years.

Don't think having a certification will land you a job.  At best, I would expect
it to get you to an interview, but in that interview, be prepared to articulate
material from the certification.  If you have an alphabet soup of
certifications, be prepared to express why you got them and what you thought was
significant from them.

For interviewers, certs make a great "small talk" question.  "Oh, I see you have
your OSCP, what did you think was the hardest part?"  You can learn a lot about
a candidate if they immediately jump in and talk about it with pride and
demonstrate their enthusiasm, or if they try to deflect and dismiss the
question.

### Conclusion ###

Certifications are not a bad thing, but you won't be able to build a career on
certifications alone.  Taking classes that don't yield a certification may, in
fact, have more of an impact on you in the long run, because you can then choose
to learn what you need/want to know, rather than learning whatever gets you a
piece of paper.  Focus on the skills you need to gain, and if you land
certifications along the way, more power to you.
