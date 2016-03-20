---
layout: post
title: "What the LastPass CLI tells us about LastPass Design"
date: 2015-09-16 05:58:19 +0000
permalink: /2015/09/16/what-the-lastpass-cli-tells-us-about-lastpass-design/
category: Security
tags: Security,Passwords
---
[LastPass](https://lastpass.com/) is a password manager that claims not to be
able to access your data.

> All sensitive data is encrypted and decrypted locally before syncing with
> LastPass. Your key never leaves your device, and is never shared with
> LastPass. Your data stays accessible only to you.

While it would be pretty hard to prove that claim, it is interesting to take
a look at how they implement their zero-knowledge encryption.  The LastPass
browser extensions are a mess of minified JavaScript, but they've been kind
enough to publish an [open-source command line
client](https://github.com/lastpass/lastpass-cli), that's quite readable C code.
I was interested to see what we could learn from the CLI, and while it won't
prove that they can't read your passwords, it will help to understand their
design.

All of my observations are from their git repo as of commit
`d96053af621f5e4b784aab3194530216b8d2ef9d`.  I'll try to include code snippets
as well to provide context in addition to line number references.

### Deriving Your Encryption Key ###

Let's start by looking at how your encryption key is determined.  Looking at
`kdf.c`, we see the following function:

    void kdf_decryption_key(const char *username, const char *password, int iterations, unsigned char hash[KDF_HASH_LEN])
    {
      _cleanup_free_ char *user_lower = xstrlower(username);

      if (iterations < 1)
        iterations = 1;

      if (iterations == 1)
        sha256_hash(user_lower, strlen(user_lower), password, strlen(password), hash);
      else
        pdkdf2_hash(user_lower, strlen(user_lower), password, strlen(password), iterations, hash);
      mlock(hash, KDF_HASH_LEN);
    }

A couple of things worth noting: `pdkdf2_hash` is a function that uses different
underlying functions on different platforms (OS X vs Linux), but just performs a
basic PBKDF2 operation.  It takes, in this order: salt, salt length, password,
password length, number of iterations, and output buffer.  It uses `HMAC-SHA256`
as the underlying crypto primitive.  (And the misspelling of `pbkdf2` as
`pdkdf2` is theirs, not mine.)

Also worth noting is the special case when `iterations` equals 1.  Entirely as
speculation on my part, but I suspect this indicates that they formerly did a
plain `SHA-256` (well, `SHA-256` of the username and password concatenated) for
the encryption key.  This is genuinely speculative, but why else special case 1
iteration?  1 iteration of `PBKDF2` is valid, though incredibly weak, so there
would be no need for the 1 round case.

Other than the special case, this looks to me like a perfectly normal `PBKDF2`
implementation to get a strong encryption key from the password.

### Deriving Your Login Hash ###

So, if the encryption key is generated that way, how do they authenticate users?
Obviously, using the same hash would be problematic, as LastPass will then get
the encryption key.  Obviously, passing anything with fewer rounds would just
allow someone to apply the extra rounds and derive the encryption key, so we
need something else.  Let's take a look (conveniently also in `kdf.c`):

    void kdf_login_key(const char *username, const char *password, int iterations, char hex[KDF_HEX_LEN])
    {
      unsigned char hash[KDF_HASH_LEN];
      size_t password_len;
      _cleanup_free_ char *user_lower = xstrlower(username);

      password_len = strlen(password);

      if (iterations < 1)
        iterations = 1;

      if (iterations == 1) {
        sha256_hash(user_lower, strlen(user_lower), password, password_len, hash);
        bytes_to_hex(hash, &hex, KDF_HASH_LEN);
        sha256_hash(hex, KDF_HEX_LEN - 1, password, password_len, hash);
      } else {
        pdkdf2_hash(user_lower, strlen(user_lower), password, password_len, iterations, hash);
        pdkdf2_hash(password, password_len, (char *)hash, KDF_HASH_LEN, 1, hash);
      }

      bytes_to_hex(hash, &hex, KDF_HASH_LEN);
      mlock(hex, KDF_HEX_LEN);
    }

A little bit longer than the encryption key, but pretty straightforward
nonetheless.  Assuming you have more than one iteration (as any new user would),
you get the same hash as generated for the encryption key, and then use the
password as a salt and do 1 `PBKDF2` round on the encryption key result.  This
is essentially equivalent to an `HMAC-SHA256` of the encryption key with the
password as the `HMAC` key, which means converting the login hash to the
encryption key is as difficult as finding a 1st preimage on `SHA256`.  Seems
unlikely.

It's obvious to see that there's still special-casing for
one iteration.  In that case, you get (essentially) `sha256(sha256(username +
password) + password)`.  It's still computationally infeasible to invert, but an
attacker with the hash & associated username can trivially apply a dictionary
attack to discover the original password (and hence, the encryption key).  It's
a good thing they've moved on to PBKDF2. :)

### How do they encrypt? ###

So, how do they handle encryption and decryption?  Well, it turns out that's
interesting too.  Looking at `ciper.c`, there's a lot of code for RSA crypto,
but that's only used if you're sharing passwords with another user.  What does
get interesting is when you look at their decryption method:

    char *cipher_aes_decrypt(const unsigned char *ciphertext, size_t len, const unsigned char key[KDF_HASH_LEN])
    {
      EVP_CIPHER_CTX ctx;
      char *plaintext;
      int out_len;

      if (!len)
        return NULL;

      EVP_CIPHER_CTX_init(&ctx);
      plaintext = xcalloc(len + AES_BLOCK_SIZE + 1, 1);
      if (len >= 33 && len % 16 == 1 && ciphertext[0] == '!') {
        if (!EVP_DecryptInit_ex(&ctx, EVP_aes_256_cbc(), NULL, key, (unsigned char *)(ciphertext + 1)))
          goto error;
        ciphertext += 17;
        len -= 17;
      } else {
        if (!EVP_DecryptInit_ex(&ctx, EVP_aes_256_ecb(), NULL, key, NULL))
          goto error;
      }
      if (!EVP_DecryptUpdate(&ctx, (unsigned char *)plaintext, &out_len, (unsigned char *)ciphertext, len))
        goto error;
      len = out_len;
      if (!EVP_DecryptFinal_ex(&ctx, (unsigned char *)(plaintext + out_len), &out_len))
        goto error;
      len += out_len;
      plaintext[len] = '\0';
      EVP_CIPHER_CTX_cleanup(&ctx);
      return plaintext;

    error:
      EVP_CIPHER_CTX_cleanup(&ctx);
      secure_clear(plaintext, len + AES_BLOCK_SIZE + 1);
      free(plaintext);
      return NULL;
    }

What's the significant part here?  If your eyes jump to the strange conditional,
you've found the same thing I did.  What's the difference in the resulting
OpenSSL calls?  It's subtle, but it's `EVP_aes_256_cbc()` versus `EVP_aes_256_ecb()`.
If the ciphertext begins with the letter `!`, the next 16 bytes are used as an
IV, and the mode is set to CBC.  If it doesn't begin with that, then ECB mode is
used.  This is interesting because this suggests that LastPass formerly used ECB mode for their
encryption.  If you don't know why this is bad, I strongly suggest the Wikipedia
article on [block cipher modes of
encryption](https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation#Electronic_Codebook_.28ECB.29).
Hopefully this has long been addressed and the code only remains to handle a few
edge cases for people who haven't logged in to their account in a very long
time.  (Again, this is all speculation.)

For what it's worth, just a few lines further down, you'll find the function
`cipher_aes_encrypt` that shows all the encryption operations, at least from
this client, are done in CBC mode with a random IV.

If you're wondering why the comparison looks so strange, consider this: if they
just checked the first character of the ciphertext, then 1/256 ECB-mode
encrypted ciphertexts would match that.  Since ECB mode ciphertexts are
multiples of the block length (as are CBC ciphertexts), checking for the length
to have one extra character (`len % 16 == 1`) rules out these extra cases.

### Transport Security ###

This section, in particular, is only relevant to this command line client, as
the browser extensions all use the browser's built-in communications mechanisms.
`http.c` shows us how the LastPass client communicates with their servers.  It
really attempts to emulate a fairly standard client as much as possible --
sending the `PHPSESSID` as a cookie, using HTTP POST for everything.  One very
interesting note is this line:

    curl_easy_setopt(curl, CURLOPT_SSL_CTX_FUNCTION, pin_certificate);

They pin the Thawte CA certificate for their communication to help reduce the
risk of a man-in-the-middle attack.

### Blobs, Chunks, and Fields ###

I've only had a quick look at `blob.c`, which contains their file format parsing
code, but I think I have a rough idea of how it goes.  Your entire LastPass
database is a `blob`, which consists of `chunk`s.  `chunk`s can be of many
types, one of which is an account chunk, which contains many `field`s.

Interestingly, if you look at `read_crypt_string`, it makes it obvious that,
rather than encrypting your entire LP database or encrypting each account entry,
fields are individually encrypted.  Looking at `account_parse`, you can see that
a lot of fields seem to be unused by the CLI client, but it's interesting to see
all the fields supported by LastPass.  One of the most interesting findings is,
in fact, right here:

    entry_hex(url);

It can be confirmed by using a proxy to examine the traffic, but it turns out
that the URL of sites in your LastPass account database are stored only as the
hex-encoded ASCII string.  No encryption whatsover.  So LastPass can easily
determine all of the sites that a user has accounts on.  (This is genuinely
surprising to me, but I triple-checked that this is actually the case.)

### Future Work ###

I think it would be interesting to dump the entire blob in a readable format.
There's some interesting things in there, like equivalencies between multiple
domains.  (If an attacker could append one of those, they could get credentials
for a legitimate domain sent to a domain they control.)  I'd also like to poke
at the extensions a little bit more, but reversing compiled JavaScript isn't the
most fun thing ever.  :)  (Suggestions of tools in this space would be welcome.)

One thing is important to understand: no evaluation can say for sure that
LastPass can't recover your passwords.  Even if they're doing everything right
today, they could push a new version tomorrow (extensions are generally
automatically updated) that records your master password.  It's inherent in
the model of any browser extension-based password manager.

