---
layout: post
title: "Dangers of decorator-based registries in Python"
date: 2014-10-26 18:51:13 +0000
permalink: /2014/10/26/dangers-of-decorator-based-registries-in-python/
categories: Computer,Security
tags: Flask,Software Engineering,Security
---
So [Flask](http://flask.pocoo.org/) has a really convenient mechanism for registering handlers, actions to be run before/after requests, etc.  Using decorators, Flask registers these functions to be called, as in:

    #!python
    @app.route('/')
    def homepage_handler():
        return 'Hello World'

    @app.before_request
    def do_something_before_each_request():
        ...

This is pretty convenient, and works really well, because it means you don't have to list all your routes in one place (like Django requires) but it comes with a cost.  You can end up with Python modules that are only needed for the side effects of importing them.  No functions from those modules are directly called from your other modules, but they still need to be imported *somewhere* to get the routes registered.  

Of course, if you import a module just to get its side effects, then pylint won't be aware you need this import, and will helpfully suggest that you remove it.  This generally isn't too bad, if you remove a file with views defined in it, they'll just fail, you'll notice quickly, and readd the import.

On the other hand, if you're using a `before_request` function to, say, provide CSRF protection, then you'll have a serious problem.  Of course, that's the case I found myself in.  So, you'll want to make sure that doesn't occur and use a resource from the file or disable pylint.
