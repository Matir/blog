---
layout: post
title: "ASIS CTF 2016: Binary Cloud"
category: Security
date: 2016-05-08
tags:
  - Security
  - CTF
---

Binary Cloud claims "Now you can upload any types of files, temporarily."  Let's
see what this means.

![binary cloud](/img/blog/asis-2016/binary_cloud.png)

Rule one of web challenges: check `robots.txt`:

~~~
User-Agent: *
Disallow: /
Disallow: /debug.php
Disallow: /cache
Disallow: /uploads
~~~

So we have some interesting paths there.  `debug.php` turns out to be a
`phpinfo()` page, informing us it's 'PHP Version 7.0.4-7ubuntu2'.  Interesting,
pretty new version.  I play around with the app briefly to see how it's going to
behave, and notice any file ending in `.php` is prohibited.  No direct `.php`
script upload for us.

I got back to the PHPInfo, and notice that if we look closely, we discover the OPCache is enabled, set
to a file directory (within the document root, interestingly).  This reminds me
of a [recent blog post I read](http://blog.gosecure.ca/2016/04/27/binary-webshell-through-opcache-in-php-7/).  (See kids, this is why it's important to keep up on the news in security!)

Ok, so maybe we need the ability to upload files into the cache directory.
Let's figure out how to get that.  Looking at the upload code, we see this:

~~~
<form action="upload.php?uploads" enctype="multipart/form-data" method="post">
<p>Please specify the file to upload!</p>
<input class="form-control" type="file" name="file"><br>
<input class="form-control" type="submit" value="Upload!">
</form>
~~~

When we upload, we're told it's uploaded to `uploads/filename`.  I notice the
query string of `uploads` on the form action, so I try it with a few different
paths.  If you provide any string including `cache` you get an error, which
makes me believe I'm on the right path but need to figure out how to bypass the
path checks.  This had me stumped for a long time, and I moved back and forth to
other challenges, but eventually I came back and happened upon the fact that if
you provided `//upload.php?/home/binarycloud/www/cache/`, it would work.  (More
on that later.)

So, now we need the opcache file to upload.  I spun up a Ubuntu 16.04 VM to
match the target as closely as possible.  First I needed a php file to create an
opcache for.  I noticed in the PHPInfo that there was a path blacklist,
including the obvious paths:

~~~
/home/binarycloud/www/index.php
/home/binarycloud/www/debug.php
/home/binarycloud/www/home.php
/home/binarycloud/www/upload.php
~~~

However, I also noticed that `/cache/index.php` appeared to be a script, and was
not blacklisted.  So, along with the `system_id` from our test system, I
determined the target path to be
`/home/binarycloud/www/cache/81d80d78c6ef96b89afaadc7ffc5d7ea/home/binarycloud/www/cache/index.php`.
I created a basic webshell on my test server containing `<?PHP
passthru($_GET['x']);` as `/home/binarycloud/www/cache/index.php` (the full path
is embedded in the OpCache file) and grabbed the `index.php.bin` file.  I upload
this and then visit the page `/cache/index.php?x=ls` and am happy to see a
directory listing.  From there it's just a short hop to get the flag in the root
of the system.

###Appendix###

In case you're wondering, I also grabbed the source to upload.php while I had my
shell (because I like to understand problems even after I get the flag) and here
it is:

~~~
<?php

function ew($haystack, $needle) {
    return $needle === "" || (($temp = strlen($haystack) - strlen($needle)) >= 0 && strpos($haystack, $needle, $temp) !== false);
}

function filter_directory(){
	$data = parse_url($_SERVER['REQUEST_URI']);
	$filter = ["cache", "binarycloud"];
	foreach($filter as $f){
		if(preg_match("/".$f."/i", $data['query'])){
			die("Attack Detected");
		}
	}
}

function error($msg){
	die("<script>alert('$msg');history.go(-1);</script>");
}

filter_directory();

if($_SERVER['QUERY_STRING'] && $_FILES['file']['name']){
	if(!file_exists($_SERVER['QUERY_STRING'])) error("error3");
	$name = preg_replace("/[^a-zA-Z0-9\.]/", "", basename($_FILES['file']['name']));
        if(ew($name, ".php")) error("error");
	$filename = $_SERVER['QUERY_STRING'] . "/" . $name;
	if(file_exists($filename)) error("exists");
	if (move_uploaded_file($_FILES['file']['tmp_name'], $filename)){
		die("uploaded at <a href=$filename>$filename</a><hr><a href='javascript:history.go(-1);'>Back</a>");
	}else{
		error("error");
	}
}

?>
	<hr>
	<form action="upload.php?uploads" enctype="multipart/form-data" method="post">
		<p>Please specify the file to upload!</p>
		<input class="form-control" type="file" name="file"><br>
		<input class="form-control" type="submit" value="Upload!">
	</form>
~~~

Notice that filter_directory uses parse_url on the request URI.
This means parsing a path beginning with two slashes and having a query string
beginning with a slash gets treated as a hostname up through the '?', followed
by the path, with no query string.  I'm not sure this is the right way to parse
it, but it worked for me here.  :)
