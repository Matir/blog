---
layout: post
title: "Hacker Summer Camp 2019: The DEF CON Data Duplication Village"
category: Security
date: 2019-09-05
series: Hacker Summer Camp 2019
tags:
  - DEF CON
  - Hacker Summer Camp
---

One last post from Summer Camp this year (it's been a busy month!) -- this one
about the "Data Duplication Village" at DEF CON.  In addition to talks, the Data
Duplication Village offers an opportunity to get your hands on the highest
quality hacker bits -- that is, copies of somewhere between 15 and 18TB of data
spread across 3 6TB hard drives.

I'd been curious about the DDV for a couple of years, but never participated
before.  I decided to change that when I saw [6TB Ironwolf NAS
drives](https://amzn.to/2ZJNImn) on sale a few weeks before DEF CON.  I wasn't
quite sure what to expect, as the description provided by the DDV is a little
bit sparse:

> 6TB drive 1-3: All past convention videos that DT can find - essentially a
> clone of infocon.org - building on last year's collection and re-squished with
> brand new codecs for your size constraining pleasures.
> 
> 6TB drive 2-3: freerainbowtables hash tables (lanman, mysqlsha1, NTLM) and
> word lists (1-2)
> 
> 6TB drive 3-3: freerainbowtables GSM A5/1, md5 hash tables, and software (2-2)

Drive 1-3 seems pretty straightforward, but I spent a lot of time debating if
the other two were worth getting.  (And, to be honest, I think they're cool to
have, but not sure if I'll really make good use of them.)

I want to thank the operators of the DDV for their efforts, and also my wife for
dropping off and picking up my drives while I was otherwise occupied (work
obligations).

It's worth noting that, as far as I can tell, all of the contents of the drives
here is available as a torrent, so you can always get the data that way.  On the
other hand, torrenting 15.07 TiB (16189363384 KiB to be precise) might not be
your cup of tea, especially if you have a mere 75 Mbps internet connection like
mine.

If you want a detailed list of the contents of each drive (along with
sha256sums), I've posted them [to Github](https://github.com/matir/ddv-index).
If you choose to participate next year, note that your drives must be 7200 RPM
SATA drives (apparently several people had to be turned away due to 5400 RPM
drives, which slow down the entire cloning process).

## Drive 1 ##

Drive 1 really does seem to be a copy of infocon.org, it's got dozens of
conferences archived on it, adding up to a total of 132,253 files.  Just to give
you a taste, here's a high-level index:

```
./cons
./cons/2600
./cons/44Con
./cons/ACK Security Conference
./cons/ACoD
./cons/AIDE
./cons/ANYCon
./cons/ATT&CKcon
./cons/AVTokyo
./cons/Android Security Symposium
./cons/ArchC0N
./cons/Area41
./cons/AthCon
./cons/AtlSecCon
./cons/AusCERT
./cons/BalCCon
./cons/Black Alps
./cons/Black Hat
./cons/BloomCON
./cons/Blue Hat
./cons/BodyHacking
./cons/Bornhack
./cons/BotConf
./cons/BrrCon
./cons/BruCON
./cons/CERIAS
./cons/CODE BLUE
./cons/COIS
./cons/CONFidence
./cons/COUNTERMEASURE
./cons/CYBERWARCON
./cons/CackalackyCon
./cons/CactusCon
./cons/CarolinaCon
./cons/Chaos Computer Club - Camp
./cons/Chaos Computer Club - Congress
./cons/Chaos Computer Club - CryptoCon
./cons/Chaos Computer Club - Easterhegg
./cons/Chaos Computer Club - SigInt
./cons/CharruaCon
./cons/CircleCityCon
./cons/ConVerge
./cons/CornCon
./cons/CrikeyCon
./cons/CyCon
./cons/CypherCon
./cons/DEF CON
./cons/DakotaCon
./cons/DeepSec
./cons/DefCamp
./cons/DerbyCon
./cons/DevSecCon
./cons/Disobey
./cons/DojoCon
./cons/DragonJAR
./cons/Ekoparty
./cons/Electromagnetic Field
./cons/FOSDEM
./cons/FSec
./cons/GreHack
./cons/GrrCON
./cons/HCPP
./cons/HITCON
./cons/Hack In Paris
./cons/Hack In The Box
./cons/Hack In The Random
./cons/Hack.lu
./cons/Hack3rcon
./cons/HackInBo
./cons/HackWest
./cons/Hackaday
./cons/Hacker Hotel
./cons/Hackers 2 Hackers Conference
./cons/Hackers At Large
./cons/Hackfest
./cons/Hacking At Random
./cons/Hackito Ergo Sum
./cons/Hacks In Taiwan
./cons/Hacktivity
./cons/Hash Days
./cons/HouSecCon
./cons/ICANN
./cons/IEEE Security and Privacy
./cons/IETF
./cons/IRISSCERT
./cons/Infiltrate
./cons/InfoWarCon
./cons/Insomnihack
./cons/KazHackStan
./cons/KiwiCon
./cons/LASCON
./cons/LASER
./cons/LangSec
./cons/LayerOne
./cons/LevelUp
./cons/LocoMocoSec
./cons/Louisville Metro InfoSec
./cons/MISP Summit
./cons/NANOG
./cons/NoNameCon
./cons/NolaCon
./cons/NorthSec
./cons/NotACon
./cons/NotPinkCon
./cons/Nuit Du Hack
./cons/NullCon
./cons/O'Reilly Security
./cons/OISF
./cons/OPCDE
./cons/OURSA
./cons/OWASP
./cons/Observe Hack Make
./cons/OffensiveCon
./cons/OzSecCon
./cons/PETS
./cons/PH-Neutral
./cons/Pacific Hackers
./cons/PasswordsCon
./cons/PhreakNIC
./cons/Positive Hack Days
./cons/Privacy Camp
./cons/QuahogCon
./cons/REcon
./cons/ROMHACK
./cons/RSA
./cons/RVAsec
./cons/Real World Crypto
./cons/RightsCon
./cons/RoadSec
./cons/Rooted CON
./cons/Rubicon
./cons/RuhrSec
./cons/RuxCon
./cons/S4
./cons/SANS
./cons/SEC-T
./cons/SHA2017
./cons/SIRAcon
./cons/SOURCE
./cons/SaintCon
./cons/SecTor
./cons/SecureWV
./cons/Securi-Tay
./cons/Security BSides
./cons/Security Fest
./cons/Security Onion
./cons/Security PWNing
./cons/Shakacon
./cons/ShellCon
./cons/ShmooCon
./cons/ShowMeCon
./cons/SkyDogCon
./cons/SteelCon
./cons/SummerCon
./cons/SyScan
./cons/THREAT CON
./cons/TROOPERS
./cons/TakeDownCon
./cons/Texas Cyber Summit
./cons/TheIACR
./cons/TheLongCon
./cons/TheSAS
./cons/Thotcon
./cons/Toorcon
./cons/TrustyCon
./cons/USENIX ATC
./cons/USENIX Enigma
./cons/USENIX Security
./cons/USENIX WOOT
./cons/Unrestcon
./cons/Virus Bulletin
./cons/WAHCKon
./cons/What The Hack
./cons/Wild West Hackin Fest
./cons/You Shot The Sheriff
./cons/Zero Day Con
./cons/ZeroNights
./cons/c0c0n
./cons/eth0
./cons/hardware.io
./cons/outerz0ne
./cons/r00tz Asylum
./cons/r2con
./cons/rootc0n
./cons/t2 infosec
./cons/x33fcon
./documentaries
./documentaries/Hacker Movies
./documentaries/Hacking Documentaries
./documentaries/Other
./documentaries/Pirate Documentary
./documentaries/Tech Documentary
./documentaries/Tools
./infocon.jpg
./mirrors
./mirrors/cryptome.org-July-2019.rar
./mirrors/gutenberg-15-July-2019.net.au.rar
./rainbow tables
./rainbow tables/## READ ME RAINBOW TABLES ##.txt
./rainbow tables/rainbow table software
./skills
./skills/Lock Picking
./skills/MAKE
```

## Drive 2 ##

Drive 2 contains the promised rainbow tables (lanman, ntlm, and mysqlsha1) as
well as a bunch of wordlists.  I actually wonder how a 128GB wordlist would
compare to applying rules to something like rockyou -- bigger is not always
better, and often, you want high yield unless you're trying to crack something
obscure.

```
./lanman
./lanman/lm_all-space#1-7_0
./lanman/lm_all-space#1-7_1
./lanman/lm_all-space#1-7_2
./lanman/lm_all-space#1-7_3
./lanman/lm_lm-frt-cp437-850#1-7_0
./lanman/lm_lm-frt-cp437-850#1-7_1
./lanman/lm_lm-frt-cp437-850#1-7_2
./lanman/lm_lm-frt-cp437-850#1-7_3
./mysqlsha1
./mysqlsha1/mysqlsha1_loweralpha#1-10_0
./mysqlsha1/mysqlsha1_loweralpha#1-10_1
./mysqlsha1/mysqlsha1_loweralpha#1-10_2
./mysqlsha1/mysqlsha1_loweralpha#1-10_3
./mysqlsha1/mysqlsha1_loweralpha-numeric#1-10_0
./mysqlsha1/mysqlsha1_loweralpha-numeric#1-10_16
./mysqlsha1/mysqlsha1_loweralpha-numeric#1-10_24
./mysqlsha1/mysqlsha1_loweralpha-numeric#1-10_8
./mysqlsha1/mysqlsha1_loweralpha-numeric-space#1-8_0
./mysqlsha1/mysqlsha1_loweralpha-numeric-space#1-8_1
./mysqlsha1/mysqlsha1_loweralpha-numeric-space#1-8_2
./mysqlsha1/mysqlsha1_loweralpha-numeric-space#1-8_3
./mysqlsha1/mysqlsha1_loweralpha-numeric-space#1-9_0
./mysqlsha1/mysqlsha1_loweralpha-numeric-space#1-9_1
./mysqlsha1/mysqlsha1_loweralpha-numeric-space#1-9_2
./mysqlsha1/mysqlsha1_loweralpha-numeric-space#1-9_3
./mysqlsha1/mysqlsha1_loweralpha-numeric-symbol32-space#1-7_0
./mysqlsha1/mysqlsha1_loweralpha-numeric-symbol32-space#1-7_1
./mysqlsha1/mysqlsha1_loweralpha-numeric-symbol32-space#1-7_2
./mysqlsha1/mysqlsha1_loweralpha-numeric-symbol32-space#1-7_3
./mysqlsha1/mysqlsha1_loweralpha-numeric-symbol32-space#1-8_0
./mysqlsha1/mysqlsha1_loweralpha-numeric-symbol32-space#1-8_1
./mysqlsha1/mysqlsha1_loweralpha-numeric-symbol32-space#1-8_2
./mysqlsha1/mysqlsha1_loweralpha-numeric-symbol32-space#1-8_3
./mysqlsha1/mysqlsha1_loweralpha-space#1-9_0
./mysqlsha1/mysqlsha1_loweralpha-space#1-9_1
./mysqlsha1/mysqlsha1_loweralpha-space#1-9_2
./mysqlsha1/mysqlsha1_loweralpha-space#1-9_3
./mysqlsha1/mysqlsha1_mixalpha-numeric-symbol32-space#1-7_0
./mysqlsha1/mysqlsha1_mixalpha-numeric-symbol32-space#1-7_1
./mysqlsha1/mysqlsha1_mixalpha-numeric-symbol32-space#1-7_2
./mysqlsha1/mysqlsha1_mixalpha-numeric-symbol32-space#1-7_3
./mysqlsha1/mysqlsha1_numeric#1-12_0
./mysqlsha1/mysqlsha1_numeric#1-12_1
./mysqlsha1/mysqlsha1_numeric#1-12_2
./mysqlsha1/mysqlsha1_numeric#1-12_3
./mysqlsha1/rainbow table software
./ntlm
./ntlm/ntlm_alpha-space#1-9_0
./ntlm/ntlm_alpha-space#1-9_1
./ntlm/ntlm_alpha-space#1-9_2
./ntlm/ntlm_alpha-space#1-9_3
./ntlm/ntlm_hybrid2(alpha#1-1,loweralpha#5-5,loweralpha-numeric#2-2,numeric#1-3)#0-0_0
./ntlm/ntlm_hybrid2(alpha#1-1,loweralpha#5-5,loweralpha-numeric#2-2,numeric#1-3)#0-0_1
./ntlm/ntlm_hybrid2(alpha#1-1,loweralpha#5-5,loweralpha-numeric#2-2,numeric#1-3)#0-0_2
./ntlm/ntlm_hybrid2(alpha#1-1,loweralpha#5-5,loweralpha-numeric#2-2,numeric#1-3)#0-0_3
./ntlm/ntlm_hybrid2(loweralpha#7-7,numeric#1-3)#0-0_0
./ntlm/ntlm_hybrid2(loweralpha#7-7,numeric#1-3)#0-0_1
./ntlm/ntlm_hybrid2(loweralpha#7-7,numeric#1-3)#0-0_2
./ntlm/ntlm_hybrid2(loweralpha#7-7,numeric#1-3)#0-0_3
./ntlm/ntlm_loweralpha-numeric#1-10_0
./ntlm/ntlm_loweralpha-numeric#1-10_16
./ntlm/ntlm_loweralpha-numeric#1-10_24
./ntlm/ntlm_loweralpha-numeric#1-10_8
./ntlm/ntlm_loweralpha-numeric-space#1-8_0
./ntlm/ntlm_loweralpha-numeric-space#1-8_1
./ntlm/ntlm_loweralpha-numeric-space#1-8_2
./ntlm/ntlm_loweralpha-numeric-space#1-8_3
./ntlm/ntlm_loweralpha-numeric-symbol32-space#1-7_0
./ntlm/ntlm_loweralpha-numeric-symbol32-space#1-7_1
./ntlm/ntlm_loweralpha-numeric-symbol32-space#1-7_2
./ntlm/ntlm_loweralpha-numeric-symbol32-space#1-7_3
./ntlm/ntlm_loweralpha-numeric-symbol32-space#1-8_0
./ntlm/ntlm_loweralpha-numeric-symbol32-space#1-8_1
./ntlm/ntlm_loweralpha-numeric-symbol32-space#1-8_2
./ntlm/ntlm_loweralpha-numeric-symbol32-space#1-8_3
./ntlm/ntlm_loweralpha-space#1-9_0
./ntlm/ntlm_loweralpha-space#1-9_1
./ntlm/ntlm_loweralpha-space#1-9_2
./ntlm/ntlm_loweralpha-space#1-9_3
./ntlm/ntlm_mixalpha-numeric#1-8_0
./ntlm/ntlm_mixalpha-numeric#1-8_1
./ntlm/ntlm_mixalpha-numeric#1-8_2
./ntlm/ntlm_mixalpha-numeric#1-8_3
./ntlm/ntlm_mixalpha-numeric#1-9_0
./ntlm/ntlm_mixalpha-numeric#1-9_16
./ntlm/ntlm_mixalpha-numeric#1-9_32
./ntlm/ntlm_mixalpha-numeric#1-9_48
./ntlm/ntlm_mixalpha-numeric-all-space#1-7_0
./ntlm/ntlm_mixalpha-numeric-all-space#1-7_1
./ntlm/ntlm_mixalpha-numeric-all-space#1-7_2
./ntlm/ntlm_mixalpha-numeric-all-space#1-7_3
./ntlm/ntlm_mixalpha-numeric-all-space#1-8_0
./ntlm/ntlm_mixalpha-numeric-all-space#1-8_16
./ntlm/ntlm_mixalpha-numeric-all-space#1-8_24
./ntlm/ntlm_mixalpha-numeric-all-space#1-8_32
./ntlm/ntlm_mixalpha-numeric-all-space#1-8_8
./ntlm/ntlm_mixalpha-numeric-space#1-7_0
./ntlm/ntlm_mixalpha-numeric-space#1-7_1
./ntlm/ntlm_mixalpha-numeric-space#1-7_2
./ntlm/ntlm_mixalpha-numeric-space#1-7_3
./ntlm/rainbow table software
./rainbow table software
./rainbow table software/Free Rainbow Tables » Distributed Rainbow Table Generation » LM, NTLM, MD5, SHA1, HALFLMCHALL, MSCACHE.mht
./rainbow table software/converti2_0.3_src.7z
./rainbow table software/converti2_0.3_win32_mingw.7z
./rainbow table software/converti2_0.3_win32_vc.7z
./rainbow table software/converti2_0.3_win64_mingw.7z
./rainbow table software/converti2_0.3_win64_vc.7z
./rainbow table software/rcracki_mt_0.7.0_linux_x86_64.7z
./rainbow table software/rcracki_mt_0.7.0_src.7z
./rainbow table software/rcracki_mt_0.7.0_win32_mingw.7z
./rainbow table software/rcracki_mt_0.7.0_win32_vc.7z
./rainbow table software/rti2formatspec.pdf
./rainbow table software/rti2rto_0.3_beta2_win32_vc.7z
./rainbow table software/rti2rto_0.3_beta2_win64_vc.7z
./rainbow table software/rti2rto_0.3_src.7z
./rainbow table software/rti2rto_0.3_win32_mingw.7z
./rainbow table software/rti2rto_0.3_win64_mingw.7z
./word lists
./word lists/SecLists-master.rar
./word lists/WPA-PSK WORDLIST 3 Final (13 GB).rar
./word lists/Word Lists archive - infocon.org.torrent
./word lists/crackstation-human-only.txt.rar
./word lists/crackstation.realuniq.rar
./word lists/fbnames.rar
./word lists/human0id word lists.rar
./word lists/openlibrary_wordlist.rar
./word lists/pwgen.rar
./word lists/pwned-passwords-2.0.txt.rar
./word lists/pwned-passwords-ordered-2.0.rar
./word lists/xsukax 128GB word list all 2017 Oct.7z
```

## Drive 3 ##

Drive 3 contains more rainbow tables, this time for A5-1 (GSM encryption), and
extensive tables for MD5.  It appears to contain the same software and wordlists
as Drive 2.

```
./A51
./A51 rainbow tables - infocon.org.torrent
./A51/Decoding-Gsm.pdf
./A51/a51_table_100.dlt
./A51/a51_table_108.dlt
./A51/a51_table_116.dlt
./A51/a51_table_124.dlt
./A51/a51_table_132.dlt
./A51/a51_table_140.dlt
./A51/a51_table_148.dlt
./A51/a51_table_156.dlt
./A51/a51_table_164.dlt
./A51/a51_table_172.dlt
./A51/a51_table_180.dlt
./A51/a51_table_188.dlt
./A51/a51_table_196.dlt
./A51/a51_table_204.dlt
./A51/a51_table_212.dlt
./A51/a51_table_220.dlt
./A51/a51_table_230.dlt
./A51/a51_table_238.dlt
./A51/a51_table_250.dlt
./A51/a51_table_260.dlt
./A51/a51_table_268.dlt
./A51/a51_table_276.dlt
./A51/a51_table_292.dlt
./A51/a51_table_324.dlt
./A51/a51_table_332.dlt
./A51/a51_table_340.dlt
./A51/a51_table_348.dlt
./A51/a51_table_356.dlt
./A51/a51_table_364.dlt
./A51/a51_table_372.dlt
./A51/a51_table_380.dlt
./A51/a51_table_388.dlt
./A51/a51_table_396.dlt
./A51/a51_table_404.dlt
./A51/a51_table_412.dlt
./A51/a51_table_420.dlt
./A51/a51_table_428.dlt
./A51/a51_table_436.dlt
./A51/a51_table_492.dlt
./A51/a51_table_500.dlt
./A51/rainbow table software
./LANMAN rainbow tables - infocon.org.torrent
./MD5 rainbow tables - infocon.org.torrent
./MySQL SHA-1 rainbow tables - infocon.org.torrent
./NTLM rainbow tables - infocon.org.torrent
./md5
./md5/md5_alpha-space#1-9_0
./md5/md5_alpha-space#1-9_1
./md5/md5_alpha-space#1-9_2
./md5/md5_alpha-space#1-9_3
./md5/md5_hybrid2(loweralpha#7-7,numeric#1-3)#0-0_0
./md5/md5_hybrid2(loweralpha#7-7,numeric#1-3)#0-0_1
./md5/md5_hybrid2(loweralpha#7-7,numeric#1-3)#0-0_2
./md5/md5_hybrid2(loweralpha#7-7,numeric#1-3)#0-0_3
./md5/md5_loweralpha#1-10_0
./md5/md5_loweralpha#1-10_1
./md5/md5_loweralpha#1-10_2
./md5/md5_loweralpha#1-10_3
./md5/md5_loweralpha-numeric#1-10_0
./md5/md5_loweralpha-numeric#1-10_16
./md5/md5_loweralpha-numeric#1-10_24
./md5/md5_loweralpha-numeric#1-10_8
./md5/md5_loweralpha-numeric-space#1-8_0
./md5/md5_loweralpha-numeric-space#1-8_1
./md5/md5_loweralpha-numeric-space#1-8_2
./md5/md5_loweralpha-numeric-space#1-8_3
./md5/md5_loweralpha-numeric-space#1-9_0
./md5/md5_loweralpha-numeric-space#1-9_1
./md5/md5_loweralpha-numeric-space#1-9_2
./md5/md5_loweralpha-numeric-space#1-9_3
./md5/md5_loweralpha-numeric-symbol32-space#1-7_0
./md5/md5_loweralpha-numeric-symbol32-space#1-7_1
./md5/md5_loweralpha-numeric-symbol32-space#1-7_2
./md5/md5_loweralpha-numeric-symbol32-space#1-7_3
./md5/md5_loweralpha-numeric-symbol32-space#1-8_0
./md5/md5_loweralpha-numeric-symbol32-space#1-8_1
./md5/md5_loweralpha-numeric-symbol32-space#1-8_2
./md5/md5_loweralpha-numeric-symbol32-space#1-8_3
./md5/md5_loweralpha-space#1-9_0
./md5/md5_loweralpha-space#1-9_1
./md5/md5_loweralpha-space#1-9_2
./md5/md5_loweralpha-space#1-9_3
./md5/md5_mixalpha-numeric#1-9_0
./md5/md5_mixalpha-numeric#1-9_0-complete
./md5/md5_mixalpha-numeric#1-9_16
./md5/md5_mixalpha-numeric#1-9_32
./md5/md5_mixalpha-numeric#1-9_48
./md5/md5_mixalpha-numeric-all-space#1-7_0
./md5/md5_mixalpha-numeric-all-space#1-7_1
./md5/md5_mixalpha-numeric-all-space#1-7_2
./md5/md5_mixalpha-numeric-all-space#1-7_3
./md5/md5_mixalpha-numeric-all-space#1-8_0
./md5/md5_mixalpha-numeric-all-space#1-8_16
./md5/md5_mixalpha-numeric-all-space#1-8_24
./md5/md5_mixalpha-numeric-all-space#1-8_32
./md5/md5_mixalpha-numeric-all-space#1-8_8
./md5/md5_mixalpha-numeric-space#1-7_0
./md5/md5_mixalpha-numeric-space#1-7_1
./md5/md5_mixalpha-numeric-space#1-7_2
./md5/md5_mixalpha-numeric-space#1-7_3
./md5/md5_mixalpha-numeric-space#1-8_0
./md5/md5_mixalpha-numeric-space#1-8_1
./md5/md5_mixalpha-numeric-space#1-8_2
./md5/md5_mixalpha-numeric-space#1-8_3
./md5/md5_numeric#1-14_0
./md5/md5_numeric#1-14_1
./md5/md5_numeric#1-14_2
./md5/md5_numeric#1-14_3
./rainbow table software
./rainbow table software/Free Rainbow Tables » Distributed Rainbow Table Generation » LM, NTLM, MD5, SHA1, HALFLMCHALL, MSCACHE.mht
./rainbow table software/converti2_0.3_src.7z
./rainbow table software/converti2_0.3_win32_mingw.7z
./rainbow table software/converti2_0.3_win32_vc.7z
./rainbow table software/converti2_0.3_win64_mingw.7z
./rainbow table software/converti2_0.3_win64_vc.7z
./rainbow table software/rcracki_mt_0.7.0_linux_x86_64.7z
./rainbow table software/rcracki_mt_0.7.0_src.7z
./rainbow table software/rcracki_mt_0.7.0_win32_mingw.7z
./rainbow table software/rcracki_mt_0.7.0_win32_vc.7z
./rainbow table software/rti2formatspec.pdf
./rainbow table software/rti2rto_0.3_beta2_win32_vc.7z
./rainbow table software/rti2rto_0.3_beta2_win64_vc.7z
./rainbow table software/rti2rto_0.3_src.7z
./rainbow table software/rti2rto_0.3_win32_mingw.7z
./rainbow table software/rti2rto_0.3_win64_mingw.7z
./word lists
./word lists/SecLists-master.rar
./word lists/WPA-PSK WORDLIST 3 Final (13 GB).rar
./word lists/Word Lists archive - infocon.org.torrent
./word lists/crackstation-human-only.txt.rar
./word lists/crackstation.realuniq.rar
./word lists/fbnames.rar
./word lists/human0id word lists.rar
./word lists/openlibrary_wordlist.rar
./word lists/pwgen.rar
./word lists/pwned-passwords-2.0.txt.rar
./word lists/pwned-passwords-ordered-2.0.rar
./word lists/xsukax 128GB word list all 2017 Oct.7z
```
