---
layout: project
title: "WebBorer: Directory Enumeration in Go"
date: 2015-12-28
---
WebBorer is a directory-enumeration tool written in Go and targeting CLI usage.

(Formerly named GoBuster, name changed to avoid collision with OJ Reeve's
excellent work.)

### Features ###

* Highly portable -- requires no runtime once compiled.
* No GUI required.
* Natively supports Socks 4, 4a, and 5 proxies.
* Supports excluding entire subpaths.
* Capable of parsing returned HTML for additional directories to parse.
* Highly scalable -- Go's parallel model allows for many workers at once.

### Contributing ###

Please see the CONTRIBUTING file in this directory.

### Copyright ###

Copyright 2015-2018 Google Inc.

WebBorer is not an official Google product (experimental or otherwise),
it is just code that happens to be owned by Google.

### Contact ###

For questions about WebBorer, contact David Tomaschik <davidtomaschik@google.com>
