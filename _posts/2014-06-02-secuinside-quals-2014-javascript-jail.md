---
layout: post
title: "Secuinside Quals 2014: Javascript Jail (Misc 200)"
date: 2014-06-02 03:43:33 +0000
permalink: /blog/secuinside-quals-2014-javascript-jail/
category: Security
tags: CTF,Security,Secuinside,Javascript
---
The challenge was pretty straightforward: connect to a service that's running a Javascript REPL, and extract the flag.  You were provided a check function that was created by the checker function given below:

    #!javascript
    function checker(flag, myRand) {
            return function (rand) {
                    function stage1() {
                            var a = Array.apply(null, new Array(Math.floor(Math.random() * 20) + 10)).map(function () {return Math.random() * 0x10000;});
                            var b = rand(a.length);
    
                            if (!Array.isArray(b)) {
                                    print("You're a cheater!");
                                    return false;
                            }
    
                            if (b.length < a.length) {
                                    print("hmm.. too short..");
                                    for (var i = 0, n = a.length - b.length; i < n; i++) {
                                            delete b[b.length];
                                            b[b.length] = [Math.random() * 0x10000];
                                    }
                            } else if (b.length > a.length) {
                                    print("hmm.. too long..");
                                    for (var i = 0, n = b.length - a.length; i < n; i++)
                                            Array.prototype.pop.apply(b);
                            }
    
                            for (var i = 0, n = b.length; i < n; i++) {
                                    if (a[i] != b[i]) {
                                            print("ddang~~");
                                            return false;
                                    }
                            }
    
                            return true;
                    }
    
                    function stage2() {
                            var a = Array.apply(null, new Array((myRand() % 20) + 10)).map(function () {return myRand() % 0x10000;});
                            var b = rand(a.length);
    
                            if (!Array.isArray(b)) {
                                    print("You're a cheater!");
                                    return false;
                            }
    
                            if (b.length < a.length) {
                                    print("hmm.. too short..");
                                    for (var i = 0, n = a.length - b.length; i < n; i++) {
                                            delete b[b.length];
                                            b[b.length] = [Math.random() * 0x10000];
                                    }
                            } else if (b.length > a.length) {
                                    print("hmm.. too long..");
                                    for (var i = 0, n = b.length - a.length; i < n; i++)
                                            Array.prototype.pop.apply(b);
                            }
    
                            for (var i = 0, n = b.length; i < n; i++) {
                                    if (a[i] != b[i]) {
                                            print("ddang~~");
                                            return false;
                                    }
                            }
    
                            return true;
                    }
    
                    print("stage1");
    
                    if (!stage1())
                            return;
    
                    print("stage2");
    
                    if (!stage2())
                            return;
    
                    print("awesome!");
                    return flag;
            };
    }

As you can tell, there are two nearly identical stages that create an array of random length (10-30) consisting of random values.  The only difference is in how the random values are generated: once from Math.random, and, in stage 2, from a function provided by the factory function.  This function was not available to us to reverse the functionality of.

So, how to solve?  I wanted to control as much of the environment as I possibly could, so I started looking for the critical functions.  I quickly realized that if we could control Math.random, stage 1 becomes trivial.  It turns out that, yes, you can redefine functions on native code objects, so a mere `Math.random = function() {return 1;};` takes care of this.  Unfortunately, stage 2 doesn't use Math.random, so how do we control it?  Well, we have Array.apply and Array.map in use to create the `a` array.  Replacing those as well gives us:

    #!javascript
    Math.random = function(){print('Random called.'); return 1;};
    f = function(l) {
      print(l);
      var foo = Array(l);
      for (i=0;i<foo.length;i++) {
        foo[i] = Math.random() * 0x10000;
      }
      foo.map = function(){return foo};
      return foo;
    };
    Array.apply = function() { return f(30); };
    check(f);

And we receive our flag.
