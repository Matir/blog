---
layout: post
title: "A Brief History of the Internet (Security-Wise)"
date: 2014-04-16 04:55:14 +0000
permalink: /2014/04/16/a-brief-history-of-the-internet-security-wise/
categories: Computer,Security
tags: InfoSec,Security,Hacking
---
I originally posted this to the [DC404 Mailing List](http://dc404.org/), but got some positive feedback, so I thought I'd post it here as well.  The broad strokes should be correct, but there might be some inaccuracies here &mdash; if you're aware of one, please let me know and I'll correct it.

There was a thread ongoing about Heartbleed, and it turned into a question of why security on the Internet is so complicated, and couldn't it be any simpler?  Well, the truth be told, security on the Internet is a house of cards.

> Part of the security problem on the Internet is also what makes the Internet so great: people using technology for something other than what it was designed for.  Back in the beginning, the internet (or even Arpanet) was a system of interconnected computers where all of the computers and operators were trusted, and we weren't shipping financial records, health records, personal communications, or whatever else over it.

> At every layer, we've had to bolt on security features, scalability features, and anything else.

> /etc/hosts is roughly what existed (though in different forms) on systems in the early years.  When a new system got added to the network, all the other operators would add it to their hosts file.  That obviously doesn't scale, so DNS gets invented.  But these are the trusting years, so DNS gets no security built in, it's just a central directory for publishing name -> IP mappings.

> Next, we'd like a way to exchange information in a linked "web" structure.  We've played with Gopher, Archie, FTP, whatever, but let's add more structure.  So along come two standards: HTTP and HTML.  Since we're publishing information for people to consume, and everyone gets the same information, and we're all trusted on this network, we just want something simple without the complexity of layers like encryption, authentication, etc., or notions of state.

> Now some people come along and want to have the ability to change content via the internet, and since we're using HTTP to fetch the content, we'll also use it for updates, so we get verbs like PUT, POST, DELETE, etc.  It's not long before someone decides that not everyone should be able to make those changes, so we'll add some authentication by having people send special headers with each state-changing request.

> It's around this time that people realize the Internet is getting too big to trust all the nodes, so we need to start thinking about encryption.  And Netscape comes along and produces SSL, which is a wrapper around any other arbitrary protocol, and offers encryption and integrity.  To ensure that, we need a way to verify the identity of the endpoint, so we need some sort of directory of that.  But of course, DNS isn't secure, isn't designed for such large payloads, so we need something else.  Something preloaded into the client, but adaptable, so we build a "Certificate Authority" that will sign the certificates that will be served by the servers.  And we'll allow some other organizations to also sign certificates.  And maybe some more.  [And more, and more...]

> So, around 1995, Netscape began to develop the idea that we could have "applications" on the Internet, and they wanted to provide interaction between the client and the server.  So they go and build a variation of Java for the client, called JavaScript.  And where do we put it?  Oh, just in the webpages.  So now we have data & executable code mixed together, and thanks to the server-side languages we're using at this point (C, Perl, etc.) we're able to output any combination of it based on user input.

> Now we come to the first dot-com era, where we have people starting to use the internet for things like "online banking" and "e-commerce".  At first, it's small potatoes, but it gets big, and keeps growing into the 21st century.  Now everything is online, from personal emails to banks, stores, governments, power plants, whatever touches a computer.  But we're still sitting on a technology stack where security was an afterthought, bolted on like training wheels on a kids bike.

> So, I know that doesn't fix your complaints, but it's important to realize how many moving parts are involved and where they came from.  If you want to know the gritty details, the best book I've seen is Zalewski's [The Tangled Web](http://www.amazon.com/gp/product/1593273886/ref=as_li_ss_tl?ie=UTF8&camp=1789&creative=390957&creativeASIN=1593273886&linkCode=as2&tag=systemovecom-20).  It's pretty technical, but it's a really great book about the state of web security.

