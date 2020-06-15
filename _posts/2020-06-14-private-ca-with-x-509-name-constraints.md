---
layout: post
title: "Private CA with X.509 Name Constraints"
category: Security
date: 2020-06-14
tags:
  - Security
  - PKI
  - TLS
---

I wanted to run a small private [Certificate
Authority](https://en.wikipedia.org/wiki/Certificate_authority) for some of my
internal services.  Since these aren't reachable from the internet, and some of
them are on network segments without internet connectivity, using a public ACME
CA like [Let's Encrypt](https://letsencrypt.org/) was inconvenient.  On the
other hand, if I run my own private CA and the keys get compromised, it could be
used to [MITM](https://en.wikipedia.org/wiki/Man-in-the-middle_attack) all my
internet traffic.  While that's unlikely to happen, I decided to look for a
better option.

It turns out that the idea of a "limited purpose" Certificate Authority is not
new.  [RFC 5280](https://tools.ietf.org/html/rfc5280) provides for something
called "Name Constraints", which allow an X.509 CA to have a scope limited to
certain names, including the parent domains of the certificates issued by the
CA.  For example, a host constraint of `.example.com` allows the CA to issue
certificates for anything under `.example.com`, but not any other host.  For
other hosts, clients will fail to validate the chain.

This hasn't always been supported by TLS libraries and browsers, but all current
browsers do support Name Constraints.  Consequently, this is an approach to
narrow the risks associated with a CA compromise for hosts other than those
covered by the constraints in the CA certificate.

<!--more-->

So it turns out that it's not super simple to set this up.  You need to
configure the correct OpenSSL extensions for the CA and the certificates, and
the easiest way is to pass them in in an ini file.

First, generate your private key and certificate signing request for the CA.  I
did mine with a 4096-bit RSA key:

```
openssl genrsa -aes256 -out ca.key.pem 4096
openssl req -new -key ca.key.pem -extensions v3_ca -batch -out ca.csr -utf8 -subj '/C=US/O=Example/OU=CA'
```

Now create a configuration file with the extensions and self-sign the CSR, using
SHA-256 for the hashes:

```
cat <<EOF >caext.ini
basicConstraints = critical, CA:TRUE
keyUsage = critical, keyCertSign, cRLSign
subjectKeyIdentifier = hash
nameConstraints = critical, permitted;DNS:.example.com
EOF
openssl x509 -req -sha256 -days 365 -in ca.csr -signkey ca.key.pem -extfile caext.ini -out ca.crt
```

You now have a CA that's constrained to only validate when it signs certificates
for hosts under `.example.com`.  We'll need to setup the serial file as well to
record the current serial of the certificates:

```
echo 1000 > ca.srl
```

Now let's create and sign a certificate using our new CA.  We'll go for
`test.example.com` in this case:

```
openssl genrsa -aes256 -out test.key.pem 2048
openssl req -new -key test.key.pem -days 365 -extensions v3_ca -batch -out test.csr -utf8 -subj '/CN=test.example.com'
cat <<'EOF' >certext.ini                                              ✘ 1
basicConstraints        = critical,CA:false
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always
nsCertType              = server
authorityKeyIdentifier  = keyid,issuer:always
keyUsage                = critical, digitalSignature, keyEncipherment
extendedKeyUsage        = serverAuth
subjectAltName          = ${ENV::CERT_SAN}
EOF
CERT_SAN=DNS:test.example.com openssl x509 -req -sha256 -days 365 -in test.csr -CAkey ca.key.pem -CA ca.crt -out test.crt -extfile certext.ini
```

We use an environment variable to pass in the `subjectAltName` specification for
the extension.

Now we can use the `openssl verify` command to check the certificate against the
CA:

```
openssl verify -CAfile ca.crt test.crt
test.crt: OK
```

We can also test that the constraints work as we intend by creating another
certificate, this time for a domain under `example.org`, not `example.com`.
This should violate the name constraints and fail to verify.

```
openssl req -new -key test.key.pem -days 365 -extensions v3_ca -batch -out test2.csr -utf8 -subj '/CN=test2.example.org'
CERT_SAN=DNS:test2.example.org openssl x509 -req -sha256 -days 365 -in test2.csr -CAkey ca.key.pem -CA ca.crt -out test2.crt -extfile certext.ini
openssl verify -CAfile ca.crt test2.crt
CN = test2.example.org
error 47 at 0 depth lookup: permitted subtree violation
error test2.crt: verification failed
```

As expected, this CA is no good for a domain not in the permitted subtree of
`.example.com`.

This allows you to create a CA for one or more domains that won't be accepted by
browsers for other domains.  You can safely establish a CA for your internal
tools, private networks, etc., and not worry that a compromised CA will
compromise all your communications.  Of course, you should still take
precautions with your CA key, such as using an HSM, storing it offline, or
encrypting it appropriately.
