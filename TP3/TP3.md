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

```powershell
[user1@TP3-Linux yt]$ systemctl status yt
● yt.service - Service for downloading youtube video
     Loaded: loaded (/etc/systemd/system/yt.service; disabled; vendor preset: disabled)
     Active: active (running) since Mon 2022-12-12 15:50:06 CET; 57s ago
   Main PID: 3713 (yt-v2.sh)
      Tasks: 2 (limit: 5877)
     Memory: 612.0K
        CPU: 4.994s
     CGroup: /system.slice/yt.service
             ├─3713 /bin/bash /srv/yt/yt-v2.sh
             └─3743 sleep 5

Dec 12 15:50:06 TP3-Linux systemd[1]: Started Service for downloading youtube video.
Dec 12 15:50:06 TP3-Linux yt-v2.sh[3713]: [INFO] The directory /downloads already exists.
Dec 12 15:50:12 TP3-Linux yt-v2.sh[3713]: Video https://www.youtube.com/watch?v=jhFDyDgMVUI was downloaded.
Dec 12 15:50:13 TP3-Linux yt-v2.sh[3713]: File path : /srv/yt/downloads/One Second Video/One Second Video
```

```powershell
Dec 12 15:50:06 TP3-Linux systemd[1]: Started Service for downloading youtube video.
░░ Subject: A start job for unit yt.service has finished successfully
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░ 
░░ A start job for unit yt.service has finished successfully.
░░ 
░░ The job identifier is 2986.
Dec 12 15:50:06 TP3-Linux yt-v2.sh[3713]: [INFO] The directory /downloads already exists.
Dec 12 15:50:12 TP3-Linux yt-v2.sh[3713]: Video https://www.youtube.com/watch?v=jhFDyDgMVUI was downloaded.
Dec 12 15:50:13 TP3-Linux yt-v2.sh[3713]: File path : /srv/yt/downloads/One Second Video/One Second Video
Dec 12 15:51:20 TP3-Linux systemd[1]: Stopping Service for downloading youtube video...
░░ Subject: A stop job for unit yt.service has begun execution
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░ 
░░ A stop job for unit yt.service has begun execution.
░░ 
░░ The job identifier is 3078.
Dec 12 15:51:20 TP3-Linux systemd[1]: yt.service: Deactivated successfully.
```

