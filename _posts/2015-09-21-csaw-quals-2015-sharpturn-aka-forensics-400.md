---
layout: post
title: "CSAW Quals 2015: Sharpturn (aka Forensics 400)"
date: 2015-09-21 21:33:58 +0000
permalink: /2015/09/21/csaw-quals-2015-sharpturn-aka-forensics-400/
category: Security
tags:
  - CTF
  - Security
  - CSAW
---
The text was just:

> I think my SATA controller is dying.
>
> HINT: `git fsck -v`

And included a tarball containing a git repository.  If you ran the suggested `git fsck -v`, you'd discover that 3 commits were corrupt:

    :::text
    Checking HEAD link
    Checking object directory
    Checking directory ./objects/2b
    Checking directory ./objects/2e
    Checking directory ./objects/35
    Checking directory ./objects/4a
    Checking directory ./objects/4c
    Checking directory ./objects/7c
    Checking directory ./objects/a1
    Checking directory ./objects/cb
    Checking directory ./objects/d5
    Checking directory ./objects/d9
    Checking directory ./objects/e5
    Checking directory ./objects/ef
    Checking directory ./objects/f8
    Checking tree 2bd4c81f7261a60ecded9bae3027a46b9746fa4f
    Checking commit 2e5d553f41522fc9036bacce1398c87c2483c2d5
    error: sha1 mismatch 354ebf392533dce06174f9c8c093036c138935f3
    error: 354ebf392533dce06174f9c8c093036c138935f3: object corrupt or missing
    Checking commit 4a2f335e042db12cc32a684827c5c8f7c97fe60b
    Checking tree 4c0555b27c05dbdf044598a0601e5c8e28319f67
    Checking commit 7c9ba8a38ffe5ce6912c69e7171befc64da12d4c
    Checking tree a1607d81984206648265fbd23a4af5e13b289f83
    Checking tree cb6c9498d7f33305f32522f862bce592ca4becd5
    Checking commit d57aaf773b1a8c8e79b6e515d3f92fc5cb332860
    error: sha1 mismatch d961f81a588fcfd5e57bbea7e17ddae8a5e61333
    error: d961f81a588fcfd5e57bbea7e17ddae8a5e61333: object corrupt or missing
    Checking blob e5e5f63b462ec6012bc69dfa076fa7d92510f22f
    Checking blob efda2f556de36b9e9e1d62417c5f282d8961e2f8
    error: sha1 mismatch f8d0839dd728cb9a723e32058dcc386070d5e3b5
    error: f8d0839dd728cb9a723e32058dcc386070d5e3b5: object corrupt or missing
    Checking connectivity (32 objects)
    Checking a1607d81984206648265fbd23a4af5e13b289f83
    Checking e5e5f63b462ec6012bc69dfa076fa7d92510f22f
    Checking 4a2f335e042db12cc32a684827c5c8f7c97fe60b
    Checking cb6c9498d7f33305f32522f862bce592ca4becd5
    Checking 4c0555b27c05dbdf044598a0601e5c8e28319f67
    Checking 2bd4c81f7261a60ecded9bae3027a46b9746fa4f
    Checking 2e5d553f41522fc9036bacce1398c87c2483c2d5
    Checking efda2f556de36b9e9e1d62417c5f282d8961e2f8
    Checking 354ebf392533dce06174f9c8c093036c138935f3
    Checking d57aaf773b1a8c8e79b6e515d3f92fc5cb332860
    Checking f8d0839dd728cb9a723e32058dcc386070d5e3b5
    Checking d961f81a588fcfd5e57bbea7e17ddae8a5e61333
    Checking 7c9ba8a38ffe5ce6912c69e7171befc64da12d4c
    missing blob 354ebf392533dce06174f9c8c093036c138935f3
    missing blob f8d0839dd728cb9a723e32058dcc386070d5e3b5
    missing blob d961f81a588fcfd5e57bbea7e17ddae8a5e61333

Well, crap.  How do we fix these?  Well, I guess the good news is that the git blob format is [fairly well documented](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects).  The SHA-1 of a blob is computed by taking the string `blob `, appending the length of the blob as an ASCII-encoded decimal value, a null character, and then the blob contents itself: `blob <blob_length>\0<blob_data>`.  The final blob value as written in the objects directory of the git repository is the zlib-compressed version of this string.  This leads us to these useful functions for reading, writing, and hashing git blobs in python:

    #!python
    import hashlib
    import zlib
    
    def git_sha1(blobdata):
        return hashlib.sha1(("blob %d" % len(blobdata)) + "\0" +
                blobdata).hexdigest()
    
    
    def read_blob(filename):
        raw = open(filename).read()
        raw = zlib.decompress(raw)
        metadata, data = raw.split('\0', 1)
        _, size = metadata.split(' ')
        size = int(size)
        if len(data) != size:
            sys.stderr.write('Metadata shows %d bytes, data is %d.\n' % size,
                    len(data))
            sys.stderr.flush()
        return data
    
    
    def write_blob(filename, blob):
        with open(filename, 'w') as fp:
            fp.write(zlib.compress(('blob %d\0' % len(blob)) + blob))
            fp.flush()


We'll use these to fix each of the commits in turn, but to do that, we need to figure out the busted commits and how to fix them.  Using the combination of `git log` and `git ls-tree`, we can figure out the blobs for each commit and find that the order of the blobs is:

    git log --oneline | tac | awk '{print $1}' | while read commit ; do git ls-tree $commit ; done | grep sharp.cpp
    100644 blob efda2f556de36b9e9e1d62417c5f282d8961e2f8	sharp.cpp
    100644 blob 354ebf392533dce06174f9c8c093036c138935f3	sharp.cpp
    100644 blob d961f81a588fcfd5e57bbea7e17ddae8a5e61333	sharp.cpp
    100644 blob f8d0839dd728cb9a723e32058dcc386070d5e3b5	sharp.cpp

So, the 3 broken blobs are, in order: `354ebf3`, `d961f81`, and `f8d0839`.  We can use `git cat-file blob <id>` to see the contents of each and look for obvious corruption.  Doing this to the first file, we see a valid C++ file, with no syntactic corruption.

    #!c++
    #include <iostream>
    #include <string>
    #include <algorithm>
    
    using namespace std;
    
    int main(int argc, char **argv)
    {
    	(void)argc; (void)argv; //unused
    
    	std::string part1;
    	cout << "Part1: Enter flag:" << endl;
    	cin >> part1;
    
    	int64_t part2;
    	cout << "Part2: Input 51337:" << endl;
    	cin >> part2;
    
    	std::string part3;
    	cout << "Part3: Watch this: https://www.youtube.com/watch?v=PBwAxmrE194" << endl;
    	cin >> part3;
    
    	std::string part4;
    	cout << "Part4: C.R.E.A.M. Get da _____: " << endl;
    	cin >> part4;
    
    	return 0;
    }

Looking at line 16, we see the number 51337.  Now, maybe I read too much into it, but it looks like 31337, which we all know is a slightly common number in CTFs.  With no better reason, I decide to try replacing 51337 with 31337 and checking the blob hash.  **Works!**  Even though it's overkill, I wrote a little script to do the fix:

    #!python
    def fix(filename):
        data = read_blob(filename)
        fixed = data.replace('51337', '31337')
        write_blob('blob.fixed', fixed)
        print git_sha1(fixed)

Running it, we get the hash `354ebf392533dce06174f9c8c093036c138935f3`, and the file blob.fixed contains a new git blob, which we can place in the repository at `.git/objects/35/4ebf392533dce06174f9c8c093036c138935f3`.  (At this point, I used `git fsck -v` to verify that we're down to two corrupt blobs.  Output omitted for brevity.)

Time to fix the next commit: `d961f81`.  This includes the same 51337 -> 31337 fix, but there's more corruption this time.  This isn't so trivial, but we get a clue from the commit for this blob:

> There's only two factors. Don't let your calculator lie.

Looking at the blob, we see this section:

    cout << "Part5: Input the two prime factors of the number 270031727027." << endl;

Turns out that 270031727027 has 4 factors, so I suspect this number has gone wrong.  Let's try mutating the bytes there to find one that corrects it.  (I could try checking for two factors, but this is fast enough to not worry about it.)

    #!python
    def permute_number(n):
        for p in range(len(n)):
            for i in string.digits:
                val = n[:p] + i + n[p+1:]
                yield val
    
    
    def fix(filename):
        data = read_blob(filename)
        rawlen = len(data)
        before, after = data.replace('51337','31337').split('270031727027')
        for permute in permute_number('270031727027'):
            data = before + permute + after
            assert rawlen == len(data)
            if git_sha1(data) == target:
                print 'Found number: %s' % permute
                write_blob('blob.fixed', data)            
                break

This only takes a second to tell us that the number should be 272031727027 instead.  The SHA1 matches, and we copy it to `.git/objects/d9/61f81a588fcfd5e57bbea7e17ddae8a5e61333`.  `git fsck -v` again to check that git sees it correctly, and we're off to the final blob.  It turns out this one is very easy to fix by inspection, once we see this segment:

    #!c++
    std::string flag = calculate_flag(part1, part2, part4, factor1, factor2);
    cout << "flag{";
    cout << &lag;
    cout << "}" << endl;

There is no variable named `lag` to take a reference of.  Since the length is right, maybe we should try just changing that to `flag`.  Incorporating our previous fixes, we get this fix script:

    #!python
    def fix(filename):
        data = read_blob(filename)
        fixed = data.replace('51337', '31337')
        fixed = fixed.replace('270031727027', '272031727027')
        fixed = fixed.replace('&lag', 'flag')
        print git_sha1(fixed)
        write_blob('blob.fixed', fixed)

Again, we copy to the objects directory.  Now that `git fsck -v` reports a good repository, we reset to HEAD to get the right version of the C++ source (though we could have just taken the `fixed` variable from our script above, to be honest) and build it, then run it:

    :::text
    Part1: Enter flag:
    flag
    Part2: Input 31337:
    31337
    Part3: Watch this: https://www.youtube.com/watch?v=PBwAxmrE194
    foo
    Part4: C.R.E.A.M. Get da _____: 
    money
    Part5: Input the two prime factors of the number 272031727027.
    31357
    8675311
    flag{3b532e0a187006879d262141e16fa5f05f2e6752}

Bam!  400 points in the bank.
