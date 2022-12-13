# TP3 : We do a little scripting


## 0. Un premier script
---

```powershell
[user1@TP3-Linux srv]$ ./test.sh 
Connecté actuellement avec l'utilisateur user1.
```

## I. Script carte d'identité 
---

```powershell
[user1@TP3-Linux idcard]$ ./idcard.sh 
Machine name : TP3-Linux
OS Rocky Linux and kernel version is 5.14.0-70.26.1.el9.aarch64
IP : 192.168.64.7/24
RAM : 612Mi memory available on 951Mi total memory
Disk : 4.5G space left
Top 5 processes by RAM usage :
	- /usr/bin/python3 -s /usr/sb  4.0
	- /usr/lib/polkit-1/polkitd -  2.2
	- /usr/sbin/NetworkManager --  1.8
	- /usr/lib/systemd/systemd --  1.6
	- /usr/sbin/rsyslogd -n        1.4
Listening ports :
	- udp 68 : NetworkManager
	- udp 323 : chronyd
	- udp 546 : NetworkManager
	- udp 323 : chronyd
	- tcp 22 : sshd
	- tcp 22 : sshd
	- tcp 22 : sshd
Here is your random cat : ./cat.JPEG
```

## II. Script youtube-dl
---

```powershell
[user1@TP3-Linux yt]$ ./yt.sh https://www.youtube.com/watch?v=8gugmLjkbvI
[INFO] The directory /downloads already exists.
Video https://www.youtube.com/watch?v=8gugmLjkbvI was downloaded.
File path : /srv/yt/downloads/Bafouillages poubelles/Bafouillages poubelles
```

## III. MAKE IT A SERVICE
---


