---
layout: post
title: "Secuinside Quals 2014: Simple Login"
date: 2014-06-04 02:08:25 +0000
permalink: /blog/secuinside-quals-2014-simple-login/
category: Security
tags: CTF,Secuinside,Security
---
In this challenge, we received the source for a site with a pretty basic login functionality.  Aside from some boring forms, javascript, and css, we have this PHP library for handling the session management:

    #!php
    <?
    	class common{
    		public function getidx($id){
    			$id = mysql_real_escape_string($id);
    			$info = mysql_fetch_array(mysql_query("select idx from member where id='".$id."'"));
    			return $info[0];
    		}
    
    		public function getpasswd($id){
    			$id = mysql_real_escape_string($id);
    			$info = mysql_fetch_array(mysql_query("select password from member where id='".$id."'"));
    			return $info[0];
    		}
    
    		public function islogin(){
    			if( preg_match("/[^0-9A-Za-z]/", $_COOKIE['user_name']) ){
    	 			exit("cannot be used Special character");
    			}
    
    			if( $_COOKIE['user_name'] == "admin" )	return 0;
    
    			$salt = file_get_contents("../../long_salt.txt");
    
    			if( hash('crc32',$salt.'|'.(int)$_COOKIE['login_time'].'|'.$_COOKIE['user_name']) == $_COOKIE['hash'] ){
    				return 1;
    			}
    
    			return 0;
    		}
    
    		public function autologin(){
    
    		}
    
    		public function isadmin(){
    			if( $this->getidx($_COOKIE['user_name']) == 1){
    				return 1;
    			}
    
    			return 0;
    		}
    
    		public function insertmember($id, $password){
    			$id = mysql_real_escape_string($id);
    			mysql_query("insert into member(id, password) values('".$id."', '".$password."')") or die();
    
    			return 1;
    		}
    	}
    ?>

Some first impressions:

- MySQL calls seem to be properly escaped.
- The auth cookie is using the super-weak crc32.
- Setting the user_name cookie to 'admin' won't work out for us.

In index.php, we see:

    #!php
    if($common->islogin()){
            if($common->isadmin())  $f = "Flag is : ".__FLAG__;
            else $f = "Hello, Guest!";

So, presumably, the correct user is actually 'admin', but we can't log in as that.  So what to do?  Well, after playing around for a bit, I realized one important point.  By default, [MySQL uses case-insensitive string comparisons](https://dev.mysql.com/doc/refman/5.0/en/case-sensitivity.html) but, of course, PHP's `==` operator is case-sensitive.  So a mixed-case version of `admin` will pass the test in `islogin()` but will return the user we want in `getidx()`, but we can't log in as any variation of `admin` as the password will still be needed.

That brings us to the hash.  Perhaps we could fake the hash for an uppercased `admin` user?  While we could probably brute force the salt, that would take a while.  However, `crc32` is vulnerable to trivial hash length extension attacks, if you can set the internal state to an existing hash.  That is: `crc32(a+b) == crc32(b, crc32(a))`.  So, since the salt is at the beginning, if we have the crc32 for a user, we can easily concatenate anything on the end and still generate a valid hash.  (Assuming an implementation of crc32 that allows you to set the existing internal state.)

One rub: while python allows you to set the state, it doesn't implement the same CRC-32 as PHP!  (I thought there was only one CRC-32, but apparently the one in python's `binascii` and `zlib` modules is the `zlib` CRC-32, and the PHP hash one is the `bz2` CRC-32.)  So I was able to find the relevant lookup table for the BZ2 crc-32 and write this implementation:

    #!python
    import struct
    
    crc_table = [
       0x00000000L, 0x04c11db7L, 0x09823b6eL, 0x0d4326d9L,
       ...snip...
       0xbcb4666dL, 0xb8757bdaL, 0xb5365d03L, 0xb1f740b4L
    ]
    
    
    def bzcrc(s, init=None):
      if init:
        state = struct.unpack('>I', struct.pack('<I', ~init & 0xffffffff))[0]
      else:
        state = 0xffffffff
      for c in s:
        state = state & 0xffffffff
        state = ((state << 8) ^ (crc_table[(state >> 24) ^ (ord(c))]))
      return hex(struct.unpack('>I', struct.pack('<I', ~state & 0xffffffff))[0])

And yes, I do some weird stuff with byte-order swapping, but it works for the one off.  So, we logged in as the user 'a', got a hash, then changed the user_name cookie to `aDMIN`, and calculated the new hash via: `bzcrc('DMIN', <existing hash>)`.  Updated the hash cookie, refresh, and we've got a flag.
