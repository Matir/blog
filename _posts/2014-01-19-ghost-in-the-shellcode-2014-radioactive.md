---
layout: post
title: "Ghost in the Shellcode 2014: Radioactive"
date: 2014-01-19 20:21:46 +0000
permalink: /blog/ghost-in-the-shellcode-2014-radioactive/
category: Security
tags: Security,Ghost in the Shellcode,Shadow Cats,CTF,Cryptography
---
Radioactive was a crypto challenge that executed arbitrary python code, if you could apply a correct cryptographic tag.  Source was provided, and the handler is below:

    #!python
    class RadioactiveHandler(SocketServer.BaseRequestHandler):
      def handle(self):
        key = open("secret", "rb").read()
        cipher = AES.new(key, AES.MODE_ECB)
    
        self.request.send("Waiting for command:\n")
        tag, command = self.request.recv(1024).strip().split(':')
        command = binascii.a2b_base64(command)
        pad = "\x00" * (16 - (len(command) % 16))
        command += pad
    
        blocks = [command[x:x+16] for x in xrange(0, len(command), 16)]
        cts = [str_to_bytes(cipher.encrypt(block)) for block in blocks]
        for block in cts:
          print ''.join(chr(x) for x in block).encode('hex')
    
        command = command[:-len(pad)]
    
        t = reduce(lambda x, y: [xx^yy for xx, yy in zip(x, y)], cts)
        t = ''.join([chr(x) for x in t]).encode('hex')
    
        match = True
        print tag, t
        for i, j in zip(tag, t):
          if i != j:
            match = False
    
        del key
        del cipher
    
        if not match:
          self.request.send("Checks failed!\n")
        eval(compile(command, "script", "exec"))
    
        return

So, it looks for a tag:command pair, where the tag is hex-encoded and the command is base64 encode.  The command must be valid python, passed through compile and eval, so you'll need to send a response back to yourself via self.request.send.

So how's the tag calculated?  Every 16-byte block of the command is encrypted in AES-ECB mode (so, two identical plaintexts == two identical ciphertexts) and then the encrypted blocks are xored together, producing the final tag.  My first thought was to generate a plaintext such that len(plain) % 16 == 0, then repeat it twice, so the XORs will cancel out and give a tag of 00...00.  Unfortunately, the padding must be at least one byte long, and my plaintext [cannot contain null bytes](http://docs.python.org/2/library/functions.html#compile).

So, we were also provided some sample code.  One such example, decoded from its base64 representation, turns out to be:

    #!python
    import os
    
    self.request.send("Send command to eval: \n")
    cmd = self.request.recv(1024).strip()
    
    
    good = True
    for b in cmd:
    	if b not in '0123456789+-=/%^* ()':
    		good = False
    
    if good:
    	self.request.send(str(eval(cmd)) + "\n")
    else:
    	self.request.send("???\n")

It turns out the line good = False (and two trailing newlines) are their own 16-byte block.  We can append "good = True \n\n" to reset the value of true, and append it a 2nd time to get our tag to come out correctly.  Then we can simply provide <code>self.request.send(open('key').read())</code> when we receive our "Send command to eval:" prompt.  And this got our flag, but it turns out there are two simpler solutions.

#### Alternate solution 1
Provide your own code as a multiple of 16.  Provide it again.  This gives you a tag of 00...00.  But we know this doesn't work.  So instead, append one of the code samples provided, and use the tag for that, as 0{16} ^ known_tag = known_tag.

#### Alternate solution 2
Start your input with : followed by whatever base-64 encoded code you want.  If you provide no tag at all, then the loop for tag comparison is never checked, leaving match=True.  (This was probably an accident in the design of the problem, possibly inteding to provide constant-time tag comparison.  As a side note, that tag comparison is not even constant time, even for strings of the proper length.)
