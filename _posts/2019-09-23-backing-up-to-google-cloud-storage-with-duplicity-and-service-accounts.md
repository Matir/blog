---
layout: post
title: "Backing up to Google Cloud Storage with Duplicity and Service Accounts"
category: Computer
date: 2019-09-23
tags:
  - Linux
  - Backups
---
I wanted to use [duplicity](http://duplicity.nongnu.org/) to backup to [Google
Cloud Storage](https://cloud.google.com/storage/).  I looked into it briefly and
found that the [boto](http://boto.cloudhackers.com/en/latest/) library,
originally for AWS, also supports GCS, but only using authorization tokens.  I'd
rather use a service account, for which authorization tokens are not available.

I looked into the options and the best information I could find was a [Medium
post](https://medium.com/google-cloud/how-to-make-ubuntu-backups-using-duplicity-and-google-cloud-storage-849edcc4196e),
but it also describes using authorization tokens and creating a separate
GMail/Google Apps account for the access.  I'd really prefer to go with a
service account to avoid having to sign up another account, and to be able to
use more granular ACLs for the service account.

It turns out there's a [boto plugin for GCS with OAuth2
support](https://github.com/GoogleCloudPlatform/gcs-oauth2-boto-plugin), but
enabling a boto plugin in duplicity isn't straight-forward.  You can point it to
a "plugin directory" that causes duplicity to import any python files in the
directory, but this doesn't work if you point it directly to the
`gcs_oauth2_boto_plugin` directory.

### Install Requirements ###

Install the following:

- [Duplicity](http://duplicity.nongnu.org/)
- [gcs-oauth2-boto-plugin](https://github.com/GoogleCloudPlatform/gcs-oauth2-boto-plugin)
- [Google Cloud SDK](https://cloud.google.com/sdk/)

### Create your GCS Bucket ###

Create a GCS bucket.  In my case, I set the default storage class to "nearline"
because I expect backups to be infrequently accessed (I hope), and I plan to
retain the data for the minimum 30 day retention.  It's also cheaper than
standard storage, so a great combination for backups.

![GCS Bucket Setup](/img/blog/duplicity/backups_demo_bucket.png)

### Create your service account ###

Next up, you need to create a service account and grant it the appropriate
permissions on the bucket.  Go through IAM > Service Account and create a new
service account.  You don't need to grant it any roles at this time, but at the
end, you should select to "Create key" and download a JSON-formatted service
account key.

Go back to the bucket you created, and go to the Permissions tab.  Add the
service account you just created as a "Storage Object Creator" and a "Storage
Object Viewer".

### Create the Boto Configuration ###

For this, you'll need the [Google Cloud SDK](https://cloud.google.com/sdk/) tool
`gsutil`.  Run `gsutil -e -o <path to your new config>`, and provide the JSON
file when prompted.  Note that the JSON file is only referenced by the config,
so if you move it somewhere else, you'll need to update the configuration.  (Or
move it first, then run it.)

This will create the necessary configuration for `boto` to authenticate to GCS.
You'll still need to add the support for OAuth2 authentication, so first create
an empty directory to serve as your plugin directory.  In my case, I created a
directory `~/.config/boto/plugins` for all my plugins.  In it, I created one
file called `gcs.py` whose only contents is the following:

```
import gcs_oauth2_boto_plugin
```

I then added the following to the bottom of my boto configuration file:

```
[Plugin]
plugin_directory = /home/matir/.config/boto/plugins
```

This will result in boto loading the `gcs_oauth2_boto_plugin` python module for
OAuth2 authentication on GCS when being loaded into duplicity.

### Setup the Duplicity Command ###

At this point, it's almost like running any duplicity backup.  If you chose to
place your boto configuration in a non-standard location, just set the
environment variable `BOTO_CONFIG` to point to the configuration file.  I run
the following:

```
export BOTO_CONFIG=${HOME}/.config/boto/boto_backups

duplicity \
  incremental \
  --full-if-older-than 30D \
  ${HOME} \
  gs://demo-backup-bucket
```
