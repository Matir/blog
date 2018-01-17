---
layout: post
title: "TP-Link Kasa App: SSL Verification Disabled (Fixed)"
category: Security
tags:
  - Security
  - Vulnerability
  - Advisories
excerpt:
  For an unknown period of time prior to December 2017, the Kasa "Smart Home"
  control application for Android failed to validate any TLS certificates when
  communicating to TP-Link's servers.  This app is used for control of the
  company's line of smart plugs, light bulbs, and home hub, and affected all
  phases of the use of the app, including user registration, authentication, and
  device control.
---

The TP-Link Kasa app is the Android app that TP-Link distributes to control
their Smart Home line of products, including IoT light bulbs, outlet and a home
hub.  TP-Link [describes the app as](http://www.tp-link.com/us/home-networking/smart-home/kasa.html):

> The Kasa app works with Android and iOS devices so you can control your home
> right from your smartphone or tablet. You can also use Kasa to pair TP-Link
> smart home products with any Amazon Echo, Dot, Tap and The Google Assistant for
> voice control, giving you the ability to control your home with voice commands.

For an unknown period of time prior to December 2017, this control app performed
no verification of SSL certificates when talking to TP-Link's servers.  This
included during user signup, authentication, and control of individual devices
in a user's home.

* * *

In September 2017, I was tooling around looking for an IoT device to play with.
My wife and I had joked about getting a "smart" light bulb for our bedroom so we
wouldn't have to get out of bed and turn off the light in the evenings.  (And
yes, it's definitely a 1st world problem, as are all problems solved by smart
home devices.) I was at Fry's and came across the
[LB100 by TP-Link](http://amzn.to/2DEcIOg): a $20 "Smart" light bulb.  This
seemed to fit the bill perfectly: it was both cheap enough that I could buy it
just to play around with, and if I liked it enough, we'd use it in the
never-ending quest that is so classically American: do as little effort as
possible.

I brought home the bulb and immediately ~~put it on my network and installed the
app~~.  Actually, as happens so commonly, I brought home the bulb and put it on
my "lab" network, and installed the app on my
[testing phone](http://amzn.to/2DFhAD6).  I had recently reset the phone, so I
was getting Burp Suite setup and was going to install the certificate in the
phone when I already noticed traffic going to TP-Link's servers!

At first I thought it must be HTTP traffic, perhaps for analytics or similar
functions, but then I noticed it was indicated as HTTPS.  I quickly did a double
take and double-checked the phone did not have the Burp CA certificate.  When I
confirmed it didn't, I realized I had an interesting finding without even giving
the app a try.

Thinking they might have different configurations for different parts of the
app, I went through the sign-up, login, device registration, and device control
flows, all the while seeing my requests in Burp.  They were all encrypted, but
not once did the app seem to care about the lack of a valid SSL CA.  I had no
idea why this was, but decided I would try to reverse engineer the app to figure
it out.

Unfortunately, my Android reverse engineering skills are about as sharp as an
economy class airplane knife, so I had to turn to my friend
[@itsc0rg1](https://medium.com/@itsc0rg1), who is, quite fortunately, well
versed in Android.  She pointed me at a couple of decompilers and I got into it
and discovered this (somewhat modified) code:

		private static void initializeSslConfig(com.tplinkra.iot.config.SSLConfig cfg) {
				if (cfg != null) {
						if (!com.tplinkra.common.utils.Utils.getDefault(cfg.getTrustAllCertificates(), 1)) {
								...
						} else {
								com.tplinkra.network.transport.http.TrustAllCertificates.enable();
						}
				}
		}

		...

    public static boolean getDefault(Boolean val, boolean default) {
        if (val != null) {
            default = val.booleanValue();
        }
        return default;
    }

		...

		public static void enable() {
				javax.net.ssl.HttpsURLConnection.setDefaultHostnameVerifier(new com.tplinkra.network.transport.http.TrustAllCertificates());
		}

It turns out that the default for `cfg.getTrustAllCertificates()` is a null value because it is not
explicitly configured.  The preference system being used by their application
attempts to return the contents of a Boolean, and when that Boolean is null,
defaults to true, which results in trusting all SSL certificates!

* * *

### Timeline ###

The issue was reported to TP-Link on the 20th of September 2017.  They promptly
acknowledge the issue and asked that I not disclose until their December
release.  Once the new year rolled around, I reached out to my contact there and
they confirmed the issue had been fixed in the December release, which appears
to have been around 22nd December.  The release notes do not mention the
security fix, so I consider this a "silent fix".

Kudos to TP-Link for fixing the issue -- many IoT companies do not stand behind
their products, so although they had a flaw, they dealt with it when it was
reported.

### Related Reading ###

* [Curesec Security on the HS-110 Smart Plug](https://www.curesec.com/blog/article/blog/The-HS-110-Smart-Plug-aka-Projekt-Kasa-165.html)
