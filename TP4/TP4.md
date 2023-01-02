# TP4 : Real Service

## Partie 1 : Partitionnement du serveur de stockage
---

1. Partitionner le disque à l'aide de LVM

* PV

```powershell
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sr0          11:0    1 1024M  0 rom  
vda         252:0    0    8G  0 disk 
├─vda1      252:1    0  600M  0 part /boot/efi
├─vda2      252:2    0    1G  0 part /boot
└─vda3      252:3    0  6.4G  0 part 
  ├─rl-root 253:0    0  5.6G  0 lvm  /
  └─rl-swap 253:1    0  820M  0 lvm  [SWAP]
vdb         252:16   0    2G  0 disk 
```

* VG

```powershell
[user1@storage ~]$ sudo pvcreate /dev/vdb
  Physical volume "/dev/vdb" successfully created.
```

```powershell
 "/dev/vdb" is a new physical volume of "2.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/vdb
  VG Name               
  PV Size               2.00 GiB
  Allocatable           NO
  PE Size               0   
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               e9Az3T-aafp-x9kg-88Tg-UxcD-G8Ai-eTGCPN
```

```powershell
[user1@storage ~]$ sudo vgcreate storage /dev/vdb
  Volume group "storage" successfully created
[user1@storage ~]$ sudo vgdisplay
  --- Volume group ---
  VG Name               storage
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <2.00 GiB
  PE Size               4.00 MiB
  Total PE              511
  Alloc PE / Size       0 / 0   
  Free  PE / Size       511 / <2.00 GiB
  VG UUID               cL26BG-3P0W-6Od1-Ykt1-ISYr-LXeR-DhCdQs
```

* LV

```powershell
[user1@storage ~]$ sudo lvcreate -l 100%FREE storage -n tp4_data
  Logical volume "tp4_data" created.
[user1@storage ~]$ sudo lvdisplay
  --- Logical volume ---
  LV Path                /dev/storage/tp4_data
  LV Name                tp4_data
  VG Name                storage
  LV UUID                1DEmD0-T857-wPsH-xhW0-Mh0E-Phhv-rIu0Hi
  LV Write Access        read/write
  LV Creation host, time storage, 2022-12-30 14:19:41 +0100
  LV Status              available
  # open                 0
  LV Size                <2.00 GiB
  Current LE             511
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2
```


2. Formater la partition

```powershell
[user1@storage ~]$ sudo mkfs -t ext4 /dev/storage/tp4_data
mke2fs 1.46.5 (30-Dec-2021)
Discarding device blocks: done                            
Creating filesystem with 523264 4k blocks and 130816 inodes
Filesystem UUID: db1f4729-9809-4404-9d37-7e2c7dc3d304
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done 
```

3. Monter la partition

```powershell
[user1@storage /]$ sudo mkdir /storage
[sudo] password for user1: 
[user1@storage /]$ sudo mount /dev/storage/tp4_data /storage
```

```powershell
[user1@storage /]$ df -h | grep storage
/dev/mapper/storage-tp4_data  2.0G   24K  1.9G   1% /storage
```

```powershell
[user1@storage storage]$ sudo vim test
[sudo] password for user1: 
[user1@storage storage]$ cat test 
Test
```

```powershell
[user1@storage storage]$ cat /etc/fstab 

#
# /etc/fstab
# Created by anaconda on Fri Oct 14 10:19:58 2022
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
/dev/mapper/rl-root     /                       xfs     defaults        0 0
UUID=cf5767c5-f864-4a80-bf30-a650a753f8c6 /boot                   xfs     defaults        0 0
UUID=7C84-5AF6          /boot/efi               vfat    umask=0077,shortname=winnt 0 2
/dev/mapper/rl-swap     none                    swap    defaults        0 0

/dev/storage/tp4_data /storage ext4 defaults 0 0
```

```powershell
[user1@storage /]$ sudo umount /storage
[user1@storage /]$ df -h
Filesystem           Size  Used Avail Use% Mounted on
devtmpfs             460M     0  460M   0% /dev
tmpfs                476M     0  476M   0% /dev/shm
tmpfs                191M  5.1M  186M   3% /run
/dev/mapper/rl-root  5.6G  1.2G  4.5G  20% /
/dev/vda2           1014M  200M  815M  20% /boot
/dev/vda1            599M  7.0M  592M   2% /boot/efi
tmpfs                 96M     0   96M   0% /run/user/1000
[user1@storage /]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
/boot/efi                : already mounted
none                     : ignored
mount: /storage does not contain SELinux labels.
       You just mounted a file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
/storage             : successfully mounted
```

## Partie 2 : Serveur de partage de fichiers

1. Donnez les commandes réalisées sur le serveur NFS storage.tp4.linux

```powershell
[user1@storage /]$ sudo dnf install nfs-utils
[...]

Upgraded:
  libsss_certmap-2.7.3-4.el9_1.1.aarch64    libsss_idmap-2.7.3-4.el9_1.1.aarch64    libsss_nss_idmap-2.7.3-4.el9_1.1.aarch64    libsss_sudo-2.7.3-4.el9_1.1.aarch64    sssd-client-2.7.3-4.el9_1.1.aarch64   
  sssd-common-2.7.3-4.el9_1.1.aarch64       sssd-kcm-2.7.3-4.el9_1.1.aarch64       
Installed:
  gssproxy-0.8.4-4.el9.aarch64      keyutils-1.6.1-4.el9.aarch64        libev-4.33-5.el9.aarch64    libnfsidmap-1:2.5.4-15.el9.aarch64  libtirpc-1.3.3-0.el9.aarch64  libverto-libev-0.3.2-3.el9.aarch64     
  nfs-utils-1:2.5.4-15.el9.aarch64  python3-pyyaml-5.4.1-6.el9.aarch64  quota-1:4.06-6.el9.aarch64  quota-nls-1:4.06-6.el9.noarch       rpcbind-1.2.6-5.el9.aarch64   sssd-nfs-idmap-2.7.3-4.el9_1.1.aarch64 

Complete!

```powershell
[user1@storage storage]$ ls
site_web_1  site_web_2
```

```powershell
[user1@storage storage]$ sudo chown nobody site_web_1
[user1@storage storage]$ sudo chown nobody site_web_2
[user1@storage storage]$ ls -l
total 8
drwxr-xr-x. 2 nobody root 4096 Dec 30 15:26 site_web_1
drwxr-xr-x. 2 nobody root 4096 Dec 30 15:26 site_web_2
```

```powershell
[user1@storage storage]$ cat /etc/exports

/storage/site_web_1 172.16.72.15(rw,sync,no_subtree_check)
/storage/site_web_2 172.16.72.15(rw,sync,no_subtree_check)
```

```powershell
[user1@storage storage]$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
    Drop-In: /run/systemd/generator/nfs-server.service.d
             └─order-with-mounts.conf
     Active: active (exited) since Fri 2022-12-30 15:35:18 CET; 22s ago
    Process: 11437 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
    Process: 11438 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
    Process: 11455 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=exited, status=0/SUCCESS)
   Main PID: 11455 (code=exited, status=0/SUCCESS)
        CPU: 18ms

Dec 30 15:35:18 storage systemd[1]: Starting NFS server and services...
Dec 30 15:35:18 storage systemd[1]: Finished NFS server and services.
```




2. Donnez les commandes réalisées sur le client NFS web.tp4.linux

```powershell
[user1@web ~]$ sudo dnf install nfs-utils
[...]

Upgraded:
  libsss_certmap-2.7.3-4.el9_1.1.aarch64    libsss_idmap-2.7.3-4.el9_1.1.aarch64    libsss_nss_idmap-2.7.3-4.el9_1.1.aarch64    libsss_sudo-2.7.3-4.el9_1.1.aarch64    sssd-client-2.7.3-4.el9_1.1.aarch64   
  sssd-common-2.7.3-4.el9_1.1.aarch64       sssd-kcm-2.7.3-4.el9_1.1.aarch64       
Installed:
  gssproxy-0.8.4-4.el9.aarch64      keyutils-1.6.1-4.el9.aarch64        libev-4.33-5.el9.aarch64    libnfsidmap-1:2.5.4-15.el9.aarch64  libtirpc-1.3.3-0.el9.aarch64  libverto-libev-0.3.2-3.el9.aarch64     
  nfs-utils-1:2.5.4-15.el9.aarch64  python3-pyyaml-5.4.1-6.el9.aarch64  quota-1:4.06-6.el9.aarch64  quota-nls-1:4.06-6.el9.noarch       rpcbind-1.2.6-5.el9.aarch64   sssd-nfs-idmap-2.7.3-4.el9_1.1.aarch64 

Complete
```

```powershell
[user1@web /]$ sudo mkdir /var/www/site_web_1/ -p
[user1@web /]$ sudo mkdir /var/www/site_web_2/ -p
```

```powershell
[user1@web www]$ ls
site_web_1  site_web_2
```

```powershell
[user1@web /]$ sudo mount 172.16.72.14:/storage/site_web_1 /var/www/site_web_1
[user1@web /]$ sudo mount 172.16.72.14:/storage/site_web_2 /var/www/site_web_2
```

```powershell
[user1@web site_web_1]$ sudo touch test
[sudo] password for user1: 
[user1@web site_web_1]$ ls -l
total 0
-rw-r--r--. 1 nobody nobody 0 Dec 30 15:55 test
```

```powershell
[user1@web /]$ cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Fri Oct 14 10:19:58 2022
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
/dev/mapper/rl-root     /                       xfs     defaults        0 0
UUID=cf5767c5-f864-4a80-bf30-a650a753f8c6 /boot                   xfs     defaults        0 0
UUID=7C84-5AF6          /boot/efi               vfat    umask=0077,shortname=winnt 0 2
/dev/mapper/rl-swap     none                    swap    defaults        0 0

172.16.72.14:/storage/site_web_1 /var/www/site_web_1 nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
172.16.72.14:/storage/site_web_2 /var/www/site_web_2 nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
```

## Partie 3 : Serveur web


1. Intro NGINX

2. Install

```powershell
[user1@web ~]$ sudo dnf install nginx
[...]

Installed:
  nginx-1:1.20.1-13.el9.aarch64                 nginx-core-1:1.20.1-13.el9.aarch64                 nginx-filesystem-1:1.20.1-13.el9.noarch                 rocky-logos-httpd-90.13-1.el9.noarch                

Complete!
```

3. Analyse

A) Analysez le service NGINX

* Commande ps

```powershell
[user1@web ~]$ ps -aux | grep nginx
root        1089  0.0  0.0   9648   908 ?        Ss   10:38   0:00 nginx: master process /usr/sbin/nginx
nginx       1090  0.0  0.4  13564  4552 ?        S    10:38   0:00 nginx: worker process
```

* Commande ss 

```powershell
[user1@web ~]$ ss -lapt | grep http
LISTEN 0      511          0.0.0.0:http        0.0.0.0:*           
LISTEN 0      511             [::]:http           [::]:*             
[user1@web ~]$ ss -laptn | grep 511
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*           
LISTEN 0      511             [::]:80           [::]:*  
```

* Fichier conf

```powershell
[user1@web nginx]$ cat /etc/nginx/nginx.conf | grep root
        root         /usr/share/nginx/html;
```

* Accessibilité

```powershell
[user1@web html]$ ls -l
total 12
-rw-r--r--. 1 root root 3332 Oct 31 16:35 404.html
-rw-r--r--. 1 root root 3404 Oct 31 16:35 50x.html
drwxr-xr-x. 2 root root   27 Dec 31 10:36 icons
lrwxrwxrwx. 1 root root   25 Oct 31 16:37 index.html -> ../../testpage/index.html
-rw-r--r--. 1 root root  368 Oct 31 16:35 nginx-logo.png
lrwxrwxrwx. 1 root root   14 Oct 31 16:37 poweredby.png -> nginx-logo.png
lrwxrwxrwx. 1 root root   37 Oct 31 16:37 system_noindex_logo.png -> ../../pixmaps/system-noindex-logo.png
```

4. Visite du service web 


A) Configuration du firewell

```powershell
[user1@web html]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[user1@web html]$ sudo firewall-cmd --reload
success
[user1@web html]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s1 enp0s2
  sources: 
  services: cockpit dhcpv6-client ssh
  ports: 80/tcp
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```

B) Accéder au site web

```
macbook-air-yohan:~ yohan$ curl 172.16.72.15 | HEAD
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0   769k      0 --:--:-- --:--:-- --:--:-- 1860k
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/
      
      html {
```

C) Vérifier les logs d'accès 

```powershell
[user1@web log]$ sudo cat nginx/access.log | tail -n 3
172.16.72.1 - - [31/Dec/2022:11:31:52 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.84.0" "-"
172.16.72.1 - - [31/Dec/2022:11:32:25 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.84.0" "-"
172.16.72.1 - - [31/Dec/2022:11:34:29 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.84.0" "-"
```

5. Modif de la conf du serveur web

A) Changer le port d'écoute

* modification port 8080

```powershell
[user1@web nginx]$ cat nginx.conf | grep listen
        listen       8080;
```

* Redémarrage service 

```powershell
[user1@web nginx]$ sudo systemctl status nginx | head -n 3
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
     Active: active (running) since Mon 2023-01-02 09:26:14 CET; 1min 20s ago
```

* Changement effectif 

```powershell
[user1@web nginx]$ ss -laptn | grep 8080
LISTEN 0      511          0.0.0.0:8080      0.0.0.0:*    
```

* Ouverture du port 

```powershell
[user1@web nginx]$ sudo firewall-cmd --list-all | grep 8080
  ports: 8080/tcp
```

* Curl

```powershell
MacBook-Air-Yohan:~ yohan$ curl 172.16.72.15:8080 | head -n 10
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0   702k      0 --:--:-- --:--:-- --:--:-- 1860k
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/
      
      html {
```

B) Changer l'utilisateur qui lance le service 

* Création de l'utilisateur web

```powershell
[user1@web nginx]$ sudo useradd web -m -s /bin/sh -u 2000 -p root
[user1@web nginx]$ sudo cat /etc/passwd
[...]
web:x:2000:2000::/home/web:/bin/sh
```

* Modification fichier .conf

```powershell
[user1@web nginx]$ cat nginx.conf | grep user
user web;
```

* Redémarrage du service 

```powershell
[user1@web nginx]$ sudo systemctl restart nginx
[user1@web nginx]$ sudo systemctl status nginx | head -n 3
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
     Active: active (running) since Mon 2023-01-02 09:43:20 CET; 1min 47s ago
```

* Vérification du bon fonctionnement du service 

```powershell
[user1@web nginx]$ ps -u  --user web
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
web         1025  0.0  0.4  13564  4448 ?        S    09:43   0:00 nginx: worker process
```

C) Changer l'emplacement de la racine Web

* Création d'un index.html

```powershell
[user1@web site_web_1]$ cat index.html 
Serveur web 1
```

* Modification du fichier.conf

```powershell
[user1@web site_web_1]$ cat /etc/nginx/nginx.conf | grep root
        root         /var/www/site_web_1/;
```

* Curl 

```powershell
MacBook-Air-Yohan:~ yohan$ curl 172.16.72.15:8080
Serveur web 1
```

6. Deux sites web sur un seul serveur

A) Repérez dans le fichier de conf

```powershell
[user1@web site_web_1]$ cat /etc/nginx/nginx.conf | grep conf.d
    # Load modular configuration files from the /etc/nginx/conf.d directory.
    include /etc/nginx/conf.d/*.conf;
```

B) Créez le fichier de configuration pour le premier site 

```powershell
[user1@web conf.d]$ cat site_web_1.conf 
   server {
        listen       8080;
        server_name  _;
        root         /var/www/site_web_1/;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```

C) Créez le fichier de configuration pour le deuxième site 

```powershell
[user1@web conf.d]$ cat site_web_2.conf 
   server {
        listen       8088;
        server_name  _;
        root         /var/www/site_web_2/;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```

```powershell
[user1@web conf.d]$ sudo firewall-cmd --list-all 
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s1 enp0s2
  sources: 
  services: cockpit dhcpv6-client ssh
  ports: 8080/tcp 8088/tcp
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules:
```

```powershell
[user1@web conf.d]$ sudo cat /var/www/site_web_2/index.html 
Serveur web 2
```


D) Prouvez que les deux sites sont disponibles 

```powershell
MacBook-Air-Yohan:~ yohan$ curl 172.16.72.15:8080
Serveur web 1
MacBook-Air-Yohan:~ yohan$ curl 172.16.72.15:8088
Serveur web 2
```

---