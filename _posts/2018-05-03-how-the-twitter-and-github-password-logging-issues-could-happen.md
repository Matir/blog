---
layout: post
title: "How the Twitter and GitHub Password Logging Issues Could Happen"
category: Security
date: 2018-05-03
tags:
  - Security
  - Passwords
---

There have recently been a couple of highly-publicized (at least in the security
community) issues with two tech giants logging passwords in plaintext.  First,
GitHub [found they were logging plaintext passwords on password
reset](https://www.zdnet.com/article/github-says-bug-exposed-account-passwords/).
Then, Twitter [found they were logging all plaintext
passwords](https://twitter.com/TwitterSupport/status/992132808192634881).  Let
me begin by saying that I have no insider knowledge of either bug, and I have
never worked at either Twitter or GitHub, but I enjoy randomly speculating on
the internet, so I thought I would speculate on this.  (Especially since the
[/r/netsec thread on the Twitter article](https://www.reddit.com/r/netsec/comments/8guet1/twitter_tells_all_330m_users_to_change_passwords/) is amazingly full of misconceptions.)

<!--more-->

### A Password Primer ###

A few commenters on /r/netsec seem amazed that Twitter ever sees the plaintext
password.  They seem to believe that the hashing (or "encryption" for some
users) occurs on the client.  Nope.  In very few places have I ever seen any
kind of client-side hashing (password managers being a notable exception).

In the case of both GitHub and Twitter, you can look at the HTTP requests (using
the Chrome inspector, Burp Suite, mitmproxy, or any number of tools) and see
your plaintext password being sent to the server.  Now, that's not to say it's
on the *wire* in plaintext, only in the HTTP requests.  Both sites use proper
TLS implementations to tunnel the login, so a passive observer on the wire just
sees encrypted traffic.  However, inside that encrypted traffic, your password
sits in plaintext.

Once the plaintext password arrives at the application server, your salted &
hashed password is retrieved from the database, the same salt & hash algorithm
is applied to the plaintext passwords, and the two results are compared.  If
they're the same, you're in, otherwise you get the nice "Login failed" screen.
In order for this to work, the server *must* use the same input to both of the
hash algorithms, and those inputs are the salt (from the database) and the
*plaintext* password.  So yes, the server sees your plaintext password.

Yes, it's possible to do client-side hashing, but it's complicated, and requires
sending the salt from the server to the client (or using a deterministic salt),
and possibly slow on mobile devices, and there's lots of reasons companies don't
want to do it.  Approximately the only security improvement is avoiding logging
plaintext passwords (which is, unfortunately, exactly what happened here).

### Large Scale Software ###

So another trope is "this should have been caught in code review."  Yeah, it
turns out code review is not perfect, and nobody has a full overview of every
line of code in the application.  This isn't the space program or aircraft
control systems, where the code is frozen and reviewed.  In most tech companies
(as far as I can tell), releases are cut all the time with a handful of changes
that were reviewed in isolation and occasionally have strange interactions.  It
does not surprise me at all for something like this to happen.

### How it Might Have Happened ###

I'd like to reiterate: **this is purely speculation**.  I don't know any details
at either company, and I suspect Twitter found their error because someone saw
the GitHub news and said "we should double check our logs."

Some people seem to think the login looked something like this:

    def login(username, password):
        log(username + " has password " + password)
        stored = get_stored_password(username)
        return hash(password) == stored

This seems fairly obvious, and I'd like to think it would be quickly caught by
the developer themselves, let alone any kind of code review.  However, it's far
more likely that something like this is at play:

    def login(username, password):
        service_request = {
            'service': 'login',
            'environment': get_environment(),
            'username': username,
            'password': password,
        }
        result = make_service_request(service_request)
        return result.ok()

    def make_service_request(request_definition):
        if request_definition['environment'] != 'prod':
            log('making service request: ' + repr(request_definition))
        backend = get_backend(request_definition['service'])
        return backend.issue_request(request_definition)

    def get_environment():
        return os.getenv('ENVIRONMENT')

They might even have a test like this:

    def test_make_service_request_no_logs_in_prod():
        fake_request = {'environment': 'prod'}
        make_service_request(fake_request)
        assertNotCalled(log)

All of this would look great (well, acceptable, this is a blog post, not a real
service) under code review.  We log the requests in our test environment for
debugging purposes.  It's never obvious that a login request is being logged,
and in the environment `prod` it's not.  But maybe one day our service grows and
we start deploying in multiple regions, and so we rename environments.
