---
layout: post
title: "OpenSSH Two Factor Authentication (But Not Service Accounts)"
category: Security
date: 2018-03-03
tags:
  - Security
  - System Administration
  - OpenSSH
---

Very often, people hear "SSH" and "two factor authentication" and assume you're
talking about an SSH keypair that's got the private key protected with a
passphrase.  And while this is a reasonable approximation of a two factor
system, it's not *actually* two factor authentication because the server is not
using two separate factors to authenticate the user.  The only factor is the SSH
keypair, and there's no way for the server to know if that key was protected
with a passphrase.  However, OpenSSH has supported true two factor
authentication for nearly 5 years now, so it's quite possible to build even more
robust security.

<!--more-->

In OpenSSH version 6.2, the OpenSSH developers added the
[`AuthenticationMethods`](https://www.freebsd.org/cgi/man.cgi?sshd_config(5))
configuration parameter which specifies one or more sets of authentication
methods that must succeed.  For example, to configure that an SSH public key and
the correct password for the account must be presented, you can specify:

    AuthenticationMethods publickey,password

For each method listed, it must *also* be enabled in the configuration, so this
would also require:

    PubkeyAuthentication yes
    PasswordAuthentication yes

This presents a true **two factor** authentication configuration.  It requires
both something the user has (the private key in the keypair) and something the
user knows (the password).  This way, neither password compromise (via
phishing, password reuse, etc.) nor key compromise (via stolen computer,
accidental commit to a git repository, etc.) is sufficient to compromise the
protected account on the server.

Perhaps you'd like to require that your users must present a publickey and
either come from a trusted host (host-based authentication, which is an
extremely poor choice on its own) or have the account password.  In that case
you could specify:

    AuthenticationMethods publickey,password publickey,hostbased

Once the `publickey` method has succeeded, the client will attempt both password
and hostbased authentication.  If the host is trusted, the user will immediately
be allowed access, otherwise they will be prompted for their password.

OpenSSH enforces that the authentication methods listed *must* complete in the
order listed in the configuration directive.  (More precisely, only the first
incomplete method in each group is offered at any time.)  Consequently, you
almost certainly want to make anything involving passwords be the *last* step,
or else your SSH server **can be used as a password oracle**, even if they can't
log in.  This is especially notable if your SSH server is joined to a domain or
connected to an LDAP server.  I repeat, **put the password methods last** to
avoid leaking whether or not a password is correct without the other mechanisms.

I personally prefer `keyboard-interactive` authentication to `password`.  The
former can use PAM to perform the authentication, allowing me to run the PAM
authentication stack.  The latter does a direct password check by the `sshd`
itself.  Either is fine for most installations, but having the flexibility of
PAM can be useful.  You can even enforce that *only* PAM will be used with a
configuration like the following:

    AuthenticationMethods publickey,keyboard-interactive:pam

Of course, if there's one thing I've learned, it's that SSH public key
authentication is good for automating things.  Depending on the scenario, I can
store the key on disk unencrypted, or manually load it into an SSH agent after
each reboot to keep it only in-memory.  Either way, I don't want these automated
processes to be blocked by the `sshd_config` change.  These users are restricted
in various ways, so the risk posed by their compromise is less than that of
others.

For example, this blog is maintained by pushing to a git repository on the host.
Let's call the user `blog`, and since it's fairly restricted (it uses
[`git-shell`](https://git-scm.com/docs/git-shell) for its shell and has very
restricted ACLs), I'm happy to continue to allow it to use only an SSH public
key to push.  To configure this, we can use a `Match User` block:

    AuthenticationMethods publickey,keyboard-interactive:pam

    Match User blog
        AuthenticationMethods publickey
        ForceCommand /usr/bin/git-shell -c "$SSH_ORIGINAL_COMMAND"

This requires both PAM (password) and public keypair for most users, but allows
the automated push to the blog to proceed with only the publickey.

Alternatively, maybe you want to keep things easy for most of your users, and
you don't consider their compromise a risk.  This would be typical for, say, a
shared hosting provider.  You'd like them to continue to be able to use either a
password or an SSH public key.  On the other hand, you'd like your admins to be
forced to use two factors to authenticate to the server.  If all of your admins
are in a single POSIX group (a good practice anyway) you can use something like
this:

    PubkeyAuthentication yes
    PasswordAuthentication yes

    Match Group admins
      AuthenticationMethods publickey,password

If you don't already do this, and you have a mix of trusted and untrusted (i.e.,
customers) users on your host, it might also be a good time to look at
restricting features like TCP Port Forwarding (`AllowTcpForwarding` and
`PermitOpen`), pseudo-device tunneling (`PermitTunnel`), and X12 Forwarding
(`X11Forwarding`) are permitted for general users.

While I've focused only on SSH options here, there's never been a better time to
look at options for requiring 2 factor authentication.  Note that if you own
some models of Yubikey, like the [Yubikey 4](http://amzn.to/2H0SAGz) (or
[Nano](http://amzn.to/2FeM6Dq)), you can also [use the PGP functionality of the
device to authenticate](https://developers.yubico.com/PGP/SSH_authentication/)
to SSH servers, thanks to functionality in `gpg-agent` that allows you to use a
GPG keypair to perform SSH auth.  These devices also act as hardware tokens for
sites like Google, Dropbox, GitHub, Facebook, and BitBucket with Universal
2-Factor (U2F) support.
