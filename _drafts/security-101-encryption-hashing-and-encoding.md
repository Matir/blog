---
layout: post
title: "Security 101: Encryption, Hashing, and Encoding"
category: Security
tags:
  - Encryption
---

Encryption, Hashing, and Encoding are commonly confused topics by those new to
the information security field.  I see these confused even by experienced
software engineers, by developers, and by new hackers.  It's really important to
understand the differences -- not just for semantics, but because the actual
uses of them are vastly different.

I do not claim to be the first to try to clarify this distinction, but there's
still a lack of clarity, and I wanted to include some exercises for you to give
a try.  I'm a very hands-on person myself, so I'm hoping the hands-on examples
are useful.

<!--more-->

## Encoding ##

Encoding is a manner of transforming some data from one representation to
another in a manner that can be reversed.  This encoding can be used to make
data pass through interfaces that restrict byte values (e.g., character sets),
or allow data to be printed, or other transformations that allow data to be
consumed by another system.  Some of the most commonly known encodings include
hexadecimal, Base 64, and URL Encoding.

Reversing encoding results in the exact input given (i.e., is lossless), and can
be done deterministically and requires no information other than the data
itself.  Lossless compression can be considered encoding in any format that
results in an output that is smaller than the input.

While encoding may make it so that the data is not trivially recognizable by a
human, it offers **no security** properties whatsoever.  It does not protect
data against unauthorized access, it does not make it difficult to be modified,
and it does not hide its meaning.

Base 64 encoding is commonly used to make arbitrary binary data pass through
systems only intended to accept ASCII characters.  Specifically, it uses 64
characters (hence the name Base 64) to represent data, by encoding each 6 bits
of raw data as a single output character.  Consequently, the output is
approximately 133% of the size of the input.  The default character set (as
defined in [RFC 4648](https://tools.ietf.org/html/rfc4648)) includes
the upper and lower case letters of the English alphabet, the digits 0-9, and
`+` and `/`.  The spec also defines a "URL safe" encoding where the extra
characters are `-` and `_`.

An example of base 64 encoding, including non-printable characters, using the
`base64` command line tool (`-d` is given to decode):

```
$ echo -e 'Hello\n\tWorld\n\t\t!!!' | base64
SGVsbG8KCVdvcmxkCgkJISEhCg==
$ echo 'SGVsbG8KCVdvcmxkCgkJISEhCg==' | base64 -d
Hello
        World
                !!!
```

Notice that the tabs and newlines become encoded (along with the other
characters) in a format that uses only printable characters and could easily be
included in an email, webpage, or almost any other protocol that supports text.
It is for this reason that base 64 is commonly used for things like HTTP Headers
(such as the Authorization header), tokens in URLs, and more.

Also note that nothing other than the encoded data is needed to decode it.
There's no key, no password, no secret involved, and it's completely reversible.
This demonstrates the lack of *any security property* offered by encoding.

## Encryption ##

Encryption involves the application of a code or cipher to input plaintext to
render it into "ciphertext".  Decryption is the reversal of that process,
converting "ciphertext" into "plaintext".  All secure ciphers involve the use of
a "key" that is required to encrypt or decrypt.  Very early ciphers (such as the
Caesar cipher or Vignere cipher) are not at all secure against modern
techniques.  (Actually they can usually be brute forced by hand even.)

Modern ciphers are designed to withstand "Kerckhoff's principle", which refers
to the idea that a properly designed cipher assumes your opponent has the cipher
algorithm (but not the key):

> It should not require secrecy, and it should not be a problem if it falls into
> enemy hands;

Encryption is intended to provide confidentiality (and sometimes integrity) for
data at rest or in transit.  By encrypting data, you render it unusable to
anyone who does not possess the key.  (Note that if your key is weak, someone
can perform a dictionary or brute force attack to retrieve your key.)  It is a
two way process, so it's only suitable when you want to provide confidentiality
but still be able to retrieve the plaintext.

I'll do a future Security 101 post on the correct applications of cryptography,
so I won't currently go into anything beyond saying that if you roll your own
crypto, you will do it wrong.  Even cryptosystems designed by professional
cryptographers undergo peer review and multiple revisions to arrive at something
secure.  *Do not roll your own crypto.*

Using the OpenSSL command line tool to encrypt data using the AES-256 cipher
with the password `foobarbaz`:

```
$ echo 'Hello world' | openssl enc -aes-256-cbc -pass pass:foobarbaz | hexdump -C
00000000  53 61 6c 74 65 64 5f 5f  08 65 ef 7e 17 31 5d 31  |Salted__.e.~.1]1|
00000010  55 3c d3 b7 8b a5 47 79  1d 72 16 ab fe 5a 0e 62  |U<....Gy.r...Z.b|
00000020
```

I performed a `hexdump` of the data because `openssl` would output the raw
bytes, and many of those bytes are non-printable sequences that would make no
sense (or corrupt my terminal).  Note that if you run the *exact same command*
twice, the output is different!

```
$ echo 'Hello world' | openssl enc -aes-256-cbc -pass pass:foobarbaz | hexdump -C
00000000  53 61 6c 74 65 64 5f 5f  d4 36 43 bf de 1c 9c 1e  |Salted__.6C.....|
00000010  e4 d4 72 24 97 d8 da 95  02 f5 3e 3f 60 a4 0a aa  |..r$......>?`...|
00000020
```

This is because the function that converts a password to an encryption key
incorporates a random salt and the encryption itself incorporates a random
"initialization vector."  Consequently, you can't compare two encrypted outputs
to confirm that the underlying plaintext is the same -- which also means an
attacker can't do that either!

The OpenSSL command line tool can also base 64 encode the output.  Note that
this is not part of the security of your output, this is just for the reasons
discussed above -- that the encoded output can be handled more easily through
tools expecting printable output.  Let's use that to round-trip some encrypted
data:

```
$ echo 'Hello world' | openssl enc -aes-256-cbc -pass pass:foobarbaz -base64
U2FsdGVkX18dIL775O8wHfVz5PVObQDijxwTUHiSlK4=
$ echo 'U2FsdGVkX18dIL775O8wHfVz5PVObQDijxwTUHiSlK4=' | openssl enc -d -aes-256-cbc -pass pass:foobarbaz -base64
Hello world
```

What if we get the password wrong?  Say, instead of `foobarbaz` I provide
`bazfoobar`:

```
$ echo 'U2FsdGVkX18dIL775O8wHfVz5PVObQDijxwTUHiSlK4=' | openssl enc -d -aes-256-cbc -pass pass:bazfoobar -base64
bad decrypt
140459245114624:error:06065064:digital envelope routines:EVP_DecryptFinal_ex:bad decrypt:../crypto/evp/evp_enc.c:583:
```

While the error may be a little cryptic, it's clear that this is not able to
decrypt with the wrong password, as we expect.

## Hashing ##

Hashing is a one way process that converts some amount of input to a fixed
output.  Cryptographic hashes are those that do so in a manner that is
computationally infeasible to invert (i.e., to get the input back from the
output).  Consequently, cryptographic hashes are sometimes referred to as "one
way functions" or "trapdoor functions".  Non-cryptographic hashes can be used as
basic checksums or for hash tables in memory.

Examples of cryptographic hashes include MD5 (**broken**), SHA-1 (**broken**),
SHA-256/384/512, and the SHA-3 family of functions.  Do not use anything based
on MD5 or SHA-1 for any new applications.

There are three main security properties of a cryptographic hash:

1. **Collision resistance** is the inability to find two different inputs that
   give the same output.  If a hash is not collision resistant, you can produce
   two documents that would both have the same hash value (used in digital
   signatures).  The [Shattered Attack](https://shattered.io/) was the first
   Proof of Concept for a collision attack on SHA-1.  Both inputs can be freely
   chosen by the attacker.
2. **Preimage resistance** is the inability to "invert" or "reverse" the hash
   by finding the input to the hash function that produced that hash value.  For
   example, if I tell you I have a SHA-256 hash of
   `68b1282b91de2c054c36629cb8dd447f12f096d3e3c587978dc2248444633483`, it should
   be computationally infeasible to find the input ("The quick brown fox jumped
   over the lazy dog.").
3. **2nd preimage resistance** is the inability to find a 2nd preimage: that is,
   a 2nd input that gives the same output.  In contrast to the collision attack,
   the attacker only gets to choose *one* of the inputs here -- the other is
   fixed.  (Imagine someone gives you a copy of a file, and you want to modify
   it but have the *same hash* as the file they gave you.)

Hashing is commonly used in digital signatures (as a way of condensing the data
being signed, since many public key crypto algorithms are limited in the amount
of data they can handle.  Hashes are also used for storing passwords to
authenticate users.

Note that, although preimage resistance may be present in the hashing function,
this is defined for an arbitrary input.  When hashing input from a user, the
input space may be sufficiently small that an attacker can try inputs in the
same function and check if the result is the same.  A **brute force attack**
occurs when all inputs in a certain range are tried. For example, if you know
that the hash is of a 9 digit national identifier number (i.e., a Social
Security Number), you can try all possible 9 digit numbers in the hash to find
the input that matches the hash value you have.  Alternatively, a **dictionary
attack** can be tried where the attacker tries a dictionary of common inputs to
the hash function and, again, compares the outputs to the hashes they have.

You'll often see hashes encoded in hexadecimal, though base 64 is not too
uncommon, especially with longer hash values.  The output of the hash function
itself is merely a set of bytes, so the encoding is just for convenience.
Consider the command line tools for common hashes:

```
$ echo -n 'foo bar baz' | md5sum
ab07acbb1e496801937adfa772424bf7  -
$ echo -n 'foo bar baz' | sha1sum
c7567e8b39e2428e38bf9c9226ac68de4c67dc39  -
$ echo -n 'foo bar baz' | sha256sum
dbd318c1c462aee872f41109a4dfd3048871a03dedd0fe0e757ced57dad6f2d7  -
```

Even a tiny change in the input results in a completely different output:

```
$ echo -n 'foo bar baz' | sha256sum
dbd318c1c462aee872f41109a4dfd3048871a03dedd0fe0e757ced57dad6f2d7  -
$ echo -n 'boo bar baz' | sha256sum
bd62b6e542410525d2c0d250c4f69b64e42e57e356e5260b4892afef8eacdfd3  -
```

### Salted & Strengthened Hashing ###

There are special properties that are desirable when using hashes to store
passwords for user authentication.

1. It should not be possible to tell if two users have the same password.
2. It should not be possible for an attacker to precompute a large dictionary of
   hashes of common passwords to lookup password hashes from a leak/breach.
   (Attackers would build lookup tables or more sophisticated structures called
   "rainbow tables", enabling them to quickly crack hashes.)
3. An attacker should have to attack the hashes for each user separately instead
   of being able to attack all at once.
4. It should be relatively slow to perform brute force and dictionary attacks
   against the hashes.

"Salting" is a process used to accomplish the first three goals.  A random
value, called the "salt" is added to each password when it is being hashed.
This way, two cases where the password is the same result in different hashes.
This makes precomputing all hash/password combinations prohibitively expensive,
and two users with the same password (or a user who uses the same password on
two sites) results in different hashes.  Obviously, it's necessary to include
the same salt value when validating the hash.

Sometimes you will see a password hash like
`$1$4zucQGVU$tx2SvCtH7SYaiH.4ASzNt.`.  The `$` characters separate the hash into
3 fields.  The first, `1`, indicates the hash type in use.  The next, `4zucQGVU`
is the salt for this hash, and finally, `tx2SvCtH7SYaiH.4ASzNt.` is the hash
itself.  Storing it like this allows the salt to be easily retrieved to compute
a matching hash when the password is input.

The fourth property can be achieved by making the hashing function itself slow,
using large amounts of memory, or by repeatedly hashing the password (or some
combination thereof).  This is necessary because the base hashing functions are
fast for even cryptographically secure hashes.  For example, the password
cracking program `hashcat` can compute [2.8 *Billion* plain SHA-256
hashes](https://gist.github.com/epixoip/a83d38f412b4737e99bbef804a270c40) per
second on a consumer graphics card.  On the other hand, the intentionally hard
function `scrypt` only hahses at 435 *thousand* per second.  This is more than
6000 times slower.  Both are a tiny delay to a single user logging in, but the
latter is a massive slowdown to someone hoping to crack a dump of password
hashes from a database.

## Comparison of Security Properties ##

## Misconceptions ##

### Encoding is Not Encryption ###

### Encryption is Not Hashing ###
