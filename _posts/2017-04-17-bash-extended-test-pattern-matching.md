---
layout: post
title: "Bash Extended Test & Pattern Matching"
category: Linux
date: 2017-04-17
tags:
  - Linux
  - Bash
---

While my daily driver shell is [ZSH](http://www.zsh.org/), when I script, I
tend to target Bash.  I've found it's the best mix of availability & feature
set.  (Ideally, scripts would be in pure posix shell, but then I'm missing a lot
of features that would make my life easier.  On the other hand, ZSH is not
available everywhere, and certainly many systems do not have it installed by
default.)

I've started trying to use the Bash "extended test command" (`[[`) when I write
tests in bash, because it has fewer ways you can misuse it with bad quoting (the
shell parses the whole test command rather than parsing it as arguments to a
command) and I find the operations available easier to read.  One of those
operations is pattern matching of strings, which allows for stupidly simple
substring tests and other conveniences.  Take, for example:

```
$animals="bird cat dog"
if [[ $animals == *dog* ]] ; then
  echo "We have a dog!"
fi
```

This is an easy way to see if an item is contained in a string.

Anyone who's done programming or scripting is probably aware that the equality
operator (i.e., test for equality) is a *commutative* operator.  That is to say
the following are equivalent:

```
$a="foo"
$b="foo"
if [[ $a == $b ]] ; then
  echo "a and b are equal."
fi
if [[ $b == $a ]] ; then
  echo "a and b are still equal."
fi
```

Seems obvious right?  If a equals b, then b must equal a.  So surely we can
reverse our test in the first example and get the same results.

```
$animals="bird cat dog"
if [[ *dog* == $animals ]] ; then
  echo "We have a dog!"
else
  echo "No dog found."
fi
```

Go ahead, give it a try, I'll wait here.

OK, you probably didn't even need to try it, or this would have been a
*particularly* boring blog post.  (Which isn't to say that this one is a
page turner to begin with.)  Yes, it turns out that sample prints `No dog
found.`, but obviously we have a dog in our animals.  If equality is commutative
and the pattern matching worked in the first place, then why doesn't this test
work?

Well, it turns out that the equality test operator in bash isn't really
commutative -- or more to the point, that the pattern expansion isn't
commutative.  Reading the [Bash Reference
Manual](https://www.gnu.org/software/bash/manual/html_node/Conditional-Constructs.html),
we discover that there's a catch to pattern expansion:

> When the ‘==’ and ‘!=’ operators are used, the string **to the right** of the
> operator is considered a pattern and matched according to the rules described
> below in Pattern Matching, as if the extglob shell option were enabled. The
> ‘=’ operator is identical to ‘==’. If the nocasematch shell option (see the
> description of shopt in The Shopt Builtin) is enabled, the match is performed
> without regard to the case of alphabetic characters. The return value is 0 if
> the string matches (‘==’) or does not match (‘!=’)the pattern, and 1
> otherwise. Any part of the pattern may be quoted to force the quoted portion
> to be matched as a string.

(Emphasis mine.)

It makes sense when you think about it (I can't begin to think how you would
compare two patterns) and it is at least documented, but it wasn't obvious to
me.  Until it bit me in a script -- then it became painfully obvious.

Like many of these posts, writing this is intended primarily as a future
reference to myself, but also in hopes it will be useful to someone else.  It
took me half an hour of Googling to get the right keywords to discover this
documentation (I didn't know the double bracket syntax was called the "extended
test command", which helps a lot), so hopefully it took you less time to find
this post.
