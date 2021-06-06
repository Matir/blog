---
layout: post
title: "GPU Accelerated Password Cracking in the Cloud: Speed and Cost-Effectiveness"
category: Security
date: 2021-06-05
tags:
  - Security
  - Cloud
  - Passwords
---

*Note: Though this testing was done on Google Cloud and I work at Google, this
work and blog post represent my personal work and do not represent the views of
my employer.*

As a red teamer and security researcher, I occasionally find the need to crack
some hashed passwords.  It used to be that [John the
Ripper](https://www.openwall.com/john/) was the go-to tool for the job.  With
the advent of GPGPU technologies like CUDA and OpenCL,
[hashcat](https://hashcat.net/hashcat/) quickly eclipsed John for pure speed.
Unfortunately, [graphics cards are a bit hard to come by in
2021](https://www.bbc.com/news/technology-55755820).  I decided to take a look
at the options for running `hashcat` on Google Cloud.

<!--more-->

There are several steps involved in getting `hashcat` running with CUDA, and
because I often only need to run the instance for a short period of time, I [put
together a
script](https://github.com/Matir/hacks/blob/main/cloud/thundercrack/thundercrack.py)
to spin up `hashcat` on a Google Cloud VM.  It can either run the benchmark or
spin up an instance with arbitrary flags.  It starts the instance but does *not*
stop it upon completion, so if you want to give it a try, make sure you shut
down the instance when you're done with it.  (It leaves the hashcat job running
in a [`tmux`](https://github.com/tmux/tmux/wiki) session for you to examine.)

At the moment, there are 6 available GPU accelerators on Google Cloud, spanning
the range of architectures from Kepler to Ampere (see [pricing
here](https://cloud.google.com/compute/gpus-pricing)):

* NVIDIA A100 (Ampere)
* NVIDIA T4 (Turing)
* NVIDIA V100 (Volta)
* NVIDIA P4 (Pascal)
* NVIDIA P100 (Pascal)
* NVIDIA K80 (Kepler)

## Performance Results

I chose a handful of common hashes as representative samples across the
different architectures.  These include MD5, SHA1, NTLM, `sha512crypt`, and
WPA-PBKDF2.  These represent some of the most common password cracking
situations encountered by penetration testers.  Unsurprisingly, overall
performance is most directly related to the number of CUDA cores, followed by
speed and architecture.

![Relative Performance Graph](/img/thundercrack/speeds.png){:.center}

Speeds in the graph are normalized to the slowest model in each test (the K80 in
all cases).
{:.caption}

Note that the Ampere-based A100 is 11-15 *times* as a fast as the slowest K80.
(On some of the benchmarks, it can reach 55 *times* as fast, but these are less
common.)
There's a wide range of hardware here, and depending on availability and GPU
type, you can attach from 1 to 16 GPUs to a single instance and `hashcat` can
spread the load across all of the attached GPUs.

Full results of all of the tests, using the slowest hardware as a baseline for
percentages:

<table class="small"><thead><tr><th>Algorithm</th><th colspan="2">nvidia-tesla-k80</th><th colspan="2">nvidia-tesla-p100</th><th colspan="2">nvidia-tesla-p4</th><th colspan="2">nvidia-tesla-v100</th><th colspan="2">nvidia-tesla-t4</th><th colspan="2">nvidia-tesla-a100</th></tr></thead>
<tbody>
<tr><td>0 - MD5</td><td>4.3 GH/s</td><td>100.0%</td><td>27.1 GH/s</td><td>622.2%</td><td>16.6 GH/s</td><td>382.4%</td><td>55.8 GH/s</td><td>1283.7%</td><td>18.8 GH/s</td><td>432.9%</td><td>67.8 GH/s</td><td>1559.2%</td></tr>
<tr><td>100 - SHA1</td><td>1.9 GH/s</td><td>100.0%</td><td>9.7 GH/s</td><td>497.9%</td><td>5.6 GH/s</td><td>286.6%</td><td>17.5 GH/s</td><td>905.4%</td><td>6.6 GH/s</td><td>342.8%</td><td>21.7 GH/s</td><td>1119.1%</td></tr>
<tr><td>1400 - SHA2-256</td><td>845.7 MH/s</td><td>100.0%</td><td>3.3 GH/s</td><td>389.5%</td><td>2.0 GH/s</td><td>238.6%</td><td>7.7 GH/s</td><td>904.8%</td><td>2.8 GH/s</td><td>334.8%</td><td>9.4 GH/s</td><td>1116.7%</td></tr>
<tr><td>1700 - SHA2-512</td><td>230.3 MH/s</td><td>100.0%</td><td>1.1 GH/s</td><td>463.0%</td><td>672.5 MH/s</td><td>292.0%</td><td>2.4 GH/s</td><td>1039.9%</td><td>789.9 MH/s</td><td>343.0%</td><td>3.1 GH/s</td><td>1353.0%</td></tr>
<tr><td>22000 - WPA-PBKDF2-PMKID+EAPOL (Iterations: 4095)</td><td>80.7 kH/s</td><td>100.0%</td><td>471.4 kH/s</td><td>584.2%</td><td>292.9 kH/s</td><td>363.0%</td><td>883.5 kH/s</td><td>1094.9%</td><td>318.3 kH/s</td><td>394.5%</td><td>1.1 MH/s</td><td>1354.3%</td></tr>
<tr><td>1000 - NTLM</td><td>7.8 GH/s</td><td>100.0%</td><td>49.9 GH/s</td><td>643.7%</td><td>29.9 GH/s</td><td>385.2%</td><td>101.6 GH/s</td><td>1310.6%</td><td>33.3 GH/s</td><td>429.7%</td><td>115.3 GH/s</td><td>1487.3%</td></tr>
<tr><td>3000 - LM</td><td>3.8 GH/s</td><td>100.0%</td><td>25.0 GH/s</td><td>661.9%</td><td>13.1 GH/s</td><td>347.8%</td><td>41.5 GH/s</td><td>1098.4%</td><td>19.4 GH/s</td><td>514.2%</td><td>65.1 GH/s</td><td>1722.0%</td></tr>
<tr><td>5500 - NetNTLMv1 / NetNTLMv1+ESS</td><td>5.0 GH/s</td><td>100.0%</td><td>26.6 GH/s</td><td>533.0%</td><td>16.1 GH/s</td><td>322.6%</td><td>54.9 GH/s</td><td>1100.9%</td><td>19.7 GH/s</td><td>395.6%</td><td>70.6 GH/s</td><td>1415.7%</td></tr>
<tr><td>5600 - NetNTLMv2</td><td>322.1 MH/s</td><td>100.0%</td><td>1.8 GH/s</td><td>567.5%</td><td>1.1 GH/s</td><td>349.9%</td><td>3.8 GH/s</td><td>1179.7%</td><td>1.4 GH/s</td><td>439.4%</td><td>5.0 GH/s</td><td>1538.1%</td></tr>
<tr><td>1500 - descrypt, DES (Unix), Traditional DES</td><td>161.7 MH/s</td><td>100.0%</td><td>1.1 GH/s</td><td>681.5%</td><td>515.3 MH/s</td><td>318.7%</td><td>1.7 GH/s</td><td>1033.9%</td><td>815.9 MH/s</td><td>504.6%</td><td>2.6 GH/s</td><td>1606.8%</td></tr>
<tr><td>500 - md5crypt, MD5 (Unix), Cisco-IOS $1$ (MD5) (Iterations: 1000)</td><td>2.5 MH/s</td><td>100.0%</td><td>10.4 MH/s</td><td>416.4%</td><td>6.3 MH/s</td><td>251.1%</td><td>24.7 MH/s</td><td>989.4%</td><td>8.7 MH/s</td><td>347.6%</td><td>31.5 MH/s</td><td>1260.6%</td></tr>
<tr><td>3200 - bcrypt $2\*$, Blowfish (Unix) (Iterations: 32)</td><td>2.5 kH/s</td><td>100.0%</td><td>22.9 kH/s</td><td>922.9%</td><td>13.4 kH/s</td><td>540.7%</td><td>78.4 kH/s</td><td>3155.9%</td><td>26.7 kH/s</td><td>1073.8%</td><td>135.4 kH/s</td><td>5450.9%</td></tr>
<tr><td>1800 - sha512crypt $6$, SHA512 (Unix) (Iterations: 5000)</td><td>37.9 kH/s</td><td>100.0%</td><td>174.6 kH/s</td><td>460.6%</td><td>91.6 kH/s</td><td>241.8%</td><td>369.6 kH/s</td><td>975.0%</td><td>103.5 kH/s</td><td>273.0%</td><td>535.4 kH/s</td><td>1412.4%</td></tr>
<tr><td>7500 - Kerberos 5, etype 23, AS-REQ Pre-Auth</td><td>43.1 MH/s</td><td>100.0%</td><td>383.9 MH/s</td><td>889.8%</td><td>186.7 MH/s</td><td>432.7%</td><td>1.0 GH/s</td><td>2427.2%</td><td>295.0 MH/s</td><td>683.8%</td><td>1.8 GH/s</td><td>4281.9%</td></tr>
<tr><td>13100 - Kerberos 5, etype 23, TGS-REP</td><td>32.3 MH/s</td><td>100.0%</td><td>348.8 MH/s</td><td>1080.2%</td><td>185.3 MH/s</td><td>573.9%</td><td>1.0 GH/s</td><td>3123.0%</td><td>291.7 MH/s</td><td>903.4%</td><td>1.8 GH/s</td><td>5563.8%</td></tr>
<tr><td>15300 - DPAPI masterkey file v1 (Iterations: 23999)</td><td>15.6 kH/s</td><td>100.0%</td><td>80.8 kH/s</td><td>519.0%</td><td>50.2 kH/s</td><td>322.3%</td><td>150.9 kH/s</td><td>968.9%</td><td>55.6 kH/s</td><td>356.7%</td><td>187.2 kH/s</td><td>1202.0%</td></tr>
<tr><td>15900 - DPAPI masterkey file v2 (Iterations: 12899)</td><td>8.1 kH/s</td><td>100.0%</td><td>36.7 kH/s</td><td>451.0%</td><td>22.1 kH/s</td><td>271.9%</td><td>79.9 kH/s</td><td>981.4%</td><td>31.3 kH/s</td><td>385.0%</td><td>109.2 kH/s</td><td>1341.5%</td></tr>
<tr><td>7100 - macOS v10.8+ (PBKDF2-SHA512) (Iterations: 1023)</td><td>104.1 kH/s</td><td>100.0%</td><td>442.6 kH/s</td><td>425.2%</td><td>272.5 kH/s</td><td>261.8%</td><td>994.6 kH/s</td><td>955.4%</td><td>392.5 kH/s</td><td>377.0%</td><td>1.4 MH/s</td><td>1304.0%</td></tr>
<tr><td>11600 - 7-Zip (Iterations: 16384)</td><td>91.9 kH/s</td><td>100.0%</td><td>380.5 kH/s</td><td>413.8%</td><td>217.0 kH/s</td><td>236.0%</td><td>757.8 kH/s</td><td>824.2%</td><td>266.6 kH/s</td><td>290.0%</td><td>1.1 MH/s</td><td>1218.6%</td></tr>
<tr><td>12500 - RAR3-hp (Iterations: 262144)</td><td>12.1 kH/s</td><td>100.0%</td><td>64.2 kH/s</td><td>528.8%</td><td>20.3 kH/s</td><td>167.6%</td><td>102.2 kH/s</td><td>842.3%</td><td>28.1 kH/s</td><td>231.7%</td><td>155.4 kH/s</td><td>1280.8%</td></tr>
<tr><td>13000 - RAR5 (Iterations: 32799)</td><td>10.2 kH/s</td><td>100.0%</td><td>39.6 kH/s</td><td>389.3%</td><td>24.5 kH/s</td><td>240.6%</td><td>93.2 kH/s</td><td>916.6%</td><td>30.2 kH/s</td><td>297.0%</td><td>118.7 kH/s</td><td>1167.8%</td></tr>
<tr><td>6211 - TrueCrypt RIPEMD160 + XTS 512 bit (Iterations: 1999)</td><td>66.8 kH/s</td><td>100.0%</td><td>292.4 kH/s</td><td>437.6%</td><td>177.3 kH/s</td><td>265.3%</td><td>669.9 kH/s</td><td>1002.5%</td><td>232.1 kH/s</td><td>347.3%</td><td>822.4 kH/s</td><td>1230.8%</td></tr>
<tr><td>13400 - KeePass 1 (AES/Twofish) and KeePass 2 (AES) (Iterations: 24569)</td><td>10.9 kH/s</td><td>100.0%</td><td>67.0 kH/s</td><td>617.1%</td><td>19.0 kH/s</td><td>174.8%</td><td>111.2 kH/s</td><td>1024.8%</td><td>27.3 kH/s</td><td>251.2%</td><td>139.0 kH/s</td><td>1281.0%</td></tr>
<tr><td>6800 - LastPass + LastPass sniffed (Iterations: 499)</td><td>651.9 kH/s</td><td>100.0%</td><td>2.5 MH/s</td><td>390.4%</td><td>1.5 MH/s</td><td>232.2%</td><td>6.0 MH/s</td><td>914.8%</td><td>2.0 MH/s</td><td>304.7%</td><td>7.6 MH/s</td><td>1160.0%</td></tr>
<tr><td>11300 - Bitcoin/Litecoin wallet.dat (Iterations: 200459)</td><td>1.3 kH/s</td><td>100.0%</td><td>5.0 kH/s</td><td>389.9%</td><td>3.1 kH/s</td><td>241.5%</td><td>11.4 kH/s</td><td>892.3%</td><td>4.1 kH/s</td><td>325.3%</td><td>14.4 kH/s</td><td>1129.2%</td></tr>
</tbody></table>

## Value Results

Believe it or not, *speed* doesn't tell the whole story, unless you're able to
bill the cost directly to your customer -- in that case, go straight for that
16-A100 instance.  :)

You're probably more interested in *value* however -- that is, hashes per
dollar.  This is computed based on the speed and price per hour, resulting in
hash per dollar value.  For each card, I computed the median relative
performance across all of the hashes in the default `hashcat` benchmark.  I then
divided performance by price per hour, then normalized these values again.

![Relative Value](/img/thundercrack/value.png){:.center}

Relative value is the mean speed per cost, in terms of the K80.
{:.caption}

<table><thead><tr><th>Card</th><th>Performance</th><th>Price</th><th>Value</th></tr></thead>
<tbody>
<tr><td>nvidia-tesla-k80</td><td>100.0</td><td>$0.45</td><td>1.00</td></tr>
<tr><td>nvidia-tesla-p100</td><td>519.0</td><td>$1.46</td><td>1.60</td></tr>
<tr><td>nvidia-tesla-p4</td><td>286.6</td><td>$0.60</td><td>2.15</td></tr>
<tr><td>nvidia-tesla-v100</td><td>1002.5</td><td>$2.48</td><td>1.82</td></tr>
<tr><td>nvidia-tesla-t4</td><td>356.7</td><td>$0.35</td><td>4.59</td></tr>
<tr><td>nvidia-tesla-a100</td><td>1341.5</td><td>$2.93</td><td>2.06</td></tr>
</tbody></table>

Though the NVIDIA T4 is nowhere near the fastest, it is the most efficient in
terms of cost, primarily due to its very low $0.35/hr pricing.  (At the time of
writing.)  If you have a particular hash to focus on, you may want to consider
doing the math for that hash type, but the relative performances seem to have
the same trend.  It's actually a great value.

So maybe the next time you're on an engagement and need to crack hashes, you'll
be able to figure out if the cloud is right for you.
