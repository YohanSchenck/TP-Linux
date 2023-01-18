# TP6 : Travail autour de la solution NextCloud


## Module 1 : Reverse Proxy

1. Setup

A) On utilisera NGINX comme reverse proxy


```powershell
[user1@proxy ~]$ sudo dnf install nginx
[...]
Complete!
```

```powershell
[user1@proxy ~]$ sudo systemctl start nginx
[user1@proxy ~]$ sudo systemctl enable nginx 
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service. 
[user1@proxy ~]$ sudo systemctl status nginx 
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
     Active: active (running) since Mon 2023-01-16 09:52:41 CET; 10s ago
    Process: 974 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 975 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 976 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 977 (nginx)
      Tasks: 2 (limit: 5878)
     Memory: 1.9M
        CPU: 15ms
     CGroup: /system.slice/nginx.service
             ├─977 "nginx: master process /usr/sbin/nginx"
             └─978 "nginx: worker process"

Jan 16 09:52:41 proxy.linux.tp6 systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jan 16 09:52:41 proxy.linux.tp6 nginx[975]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jan 16 09:52:41 proxy.linux.tp6 nginx[975]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Jan 16 09:52:41 proxy.linux.tp6 systemd[1]: Started The nginx HTTP and reverse proxy server.
```

```powershell
[user1@proxy ~]$ ss -lapten | grep nginx
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*     ino:19747 sk:1 cgroup:/system.slice/nginx.service <->                          
LISTEN 0      511             [::]:80           [::]:*     ino:19748 sk:4 cgroup:/system.slice/nginx.service v6only:1 <->   
```

```powershell
[user1@proxy ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[user1@proxy ~]$ sudo firewall-cmd --reload
success
[user1@proxy ~]$ sudo firewall-cmd --list-all
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

```powershell
[user1@proxy ~]$ ps -ef | grep nginx
root         977       1  0 09:52 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx        978     977  0 09:52 ?        00:00:00 nginx: worker process
user1       1040     787  0 09:58 pts/0    00:00:00 grep --color=auto nginx
```

```powershell
[user1@proxy ~]$ ip a 
[...]
3: enp0s2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 1a:1d:d4:34:2a:4a brd ff:ff:ff:ff:ff:ff
    inet 172.16.72.18/24 brd 172.16.72.255 scope global dynamic noprefixroute enp0s2
       valid_lft 85780sec preferred_lft 85780sec
    inet6 fe80::3557:1fb4:ac4d:8808/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```

```powershell
macbook-air-yohan:~ yohan$ curl 172.16.72.18 | head -n 10
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0   737k      0 --:--:-- --:--:-- --:--:-- 1488k
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

B) Configurez NGINX

```powershell
[sudo] password for user1: 
include /usr/share/nginx/modules/*.conf;
    include             /etc/nginx/mime.types;
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/default.d/*.conf;
#        include /etc/nginx/default.d/*.conf;
```

```powershell
[user1@proxy nginx]$ sudo cat nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

   # server {
   #     listen       80;
   #     listen       [::]:80;
   #     server_name  _;
   #     root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
   #     include /etc/nginx/default.d/*.conf;

   #     error_page 404 /404.html;
   #     location = /404.html {
   #     }

   #     error_page 500 502 503 504 /50x.html;
   #     location = /50x.html {
   #     }
   # }

# Settings for a TLS enabled server.
#
#    server {
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;
#        server_name  _;
#        root         /usr/share/nginx/html;
#
#        ssl_certificate "/etc/pki/nginx/server.crt";
#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout  10m;
#        ssl_ciphers PROFILE=SYSTEM;
#        ssl_prefer_server_ciphers on;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        error_page 404 /404.html;
#            location = /40x.html {
#        }
#
#        error_page 500 502 503 504 /50x.html;
#            location = /50x.html {
#        }
#    }

}
```


```powershell
[user1@proxy conf.d]$ sudo cat tp6.conf
server {
    # On indique le nom que client va saisir pour accéder au service
    # Pas d'erreur ici, c'est bien le nom de web, et pas de proxy qu'on veut ici !
    server_name web.tp6.linux;

    # Port d'écoute de NGINX
    listen 80;

    location / {
        # On définit des headers HTTP pour que le proxying se passe bien
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        # On définit la cible du proxying 
        proxy_pass http://172.16.72.11:80;
    }

    # Deux sections location recommandés par la doc NextCloud
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }

    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
}
```

```powershell
[user1@proxy etc]$ sudo systemctl restart nginx
[user1@proxy etc]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
     Active: active (running) since Mon 2023-01-16 10:13:59 CET; 15s ago
    Process: 1100 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 1101 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 1102 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 1103 (nginx)
      Tasks: 2 (limit: 5878)
     Memory: 1.9M
        CPU: 17ms
     CGroup: /system.slice/nginx.service
             ├─1103 "nginx: master process /usr/sbin/nginx"
             └─1104 "nginx: worker process"

Jan 16 10:13:59 proxy.linux.tp6 systemd[1]: nginx.service: Deactivated successfully.
Jan 16 10:13:59 proxy.linux.tp6 systemd[1]: Stopped The nginx HTTP and reverse proxy server.
Jan 16 10:13:59 proxy.linux.tp6 systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jan 16 10:13:59 proxy.linux.tp6 nginx[1101]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jan 16 10:13:59 proxy.linux.tp6 nginx[1101]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Jan 16 10:13:59 proxy.linux.tp6 systemd[1]: Started The nginx HTTP and reverse proxy server.
```

```powershell
[user1@web config]$ sudo cat config.php 
<?php
$CONFIG = array (
  'instanceid' => 'ocsuqiy4oixg',
  'passwordsalt' => '+FhHkvQQDnQFeFLQKyfcU6DkMnAn5f',
  'secret' => '48NBAgfHVP+4dFin7s/YDXS7RWxPhxgbBbQCSD5PGqwvsjVT',
  'trusted_domains' => 
  array (
	  0 => 'web.tp6.linux',
  ),
  'datadirectory' => '/var/www/tp5_nextcloud/data',
  'dbtype' => 'mysql',
  'version' => '25.0.0.15',
  'overwrite.cli.url' => 'http://web.tp5.linux',
  'dbname' => 'nextcloud',
  'dbhost' => '172.16.72.12:3306',
  'dbport' => '',
  'dbtableprefix' => 'oc_',
  'mysql.utf8mb4' => true,
  'dbuser' => 'nextcloud',
  'dbpassword' => 'pewpewpew',
  'installed' => true,
);
```

* Modifier votre fichier hosts de VOTRE PC
```powershell
macbook-air-yohan:~ yohan$ sudo cat /etc/hosts | grep tp6
172.16.72.18 web.tp6.linux
```

C) Faites en sorte de 

```powershell
[user1@web config]$ sudo firewall-cmd --set-default-zone=drop
success
[user1@web config]$ sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.16.72.18" port port="80" protocol="tcp" accept'
success
[user1@web config]$ sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.16.72.1" port port="22" protocol="tcp" accept'
[sudo] password for user1: 
success
[user1@web config]$ sudo firewall-cmd --reload
success
[user1@web config]$ sudo firewall-cmd --list-all
drop (active)
  target: DROP
  icmp-block-inversion: no
  interfaces: enp0s1 enp0s2
  sources: 
  services: 
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
	rule family="ipv4" source address="172.16.72.1" port port="22" protocol="tcp" accept
	rule family="ipv4" source address="172.16.72.18" port port="80" protocol="tcp" accept
```

D) Une fois que c'est en place 

```powershell
macbook-air-yohan:~ yohan$ ping 172.16.72.18
PING 172.16.72.18 (172.16.72.18): 56 data bytes
64 bytes from 172.16.72.18: icmp_seq=0 ttl=64 time=1.429 ms
64 bytes from 172.16.72.18: icmp_seq=1 ttl=64 time=0.960 ms
64 bytes from 172.16.72.18: icmp_seq=2 ttl=64 time=1.239 ms
^C
--- 172.16.72.18 ping statistics ---
3 packets transmitted, 3 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 0.960/1.209/1.429/0.193 ms
macbook-air-yohan:~ yohan$ ping 172.16.72.11
PING 172.16.72.11 (172.16.72.11): 56 data bytes
Request timeout for icmp_seq 0
Request timeout for icmp_seq 1
Request timeout for icmp_seq 2
^C
```

2. HTTPS

```powershell
[user1@proxy nginx]$ sudo mkdir certs
[sudo] password for user1: 
```

```powershell
[user1@proxy certs]$ sudo openssl genrsa -out ssl_certificate.key 2048
[user1@proxy certs]$ sudo openssl req -new -x509 -key ssl_certificate.key -out ssl_certificate.crt -days 365
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:FR
State or Province Name (full name) []:.
Locality Name (eg, city) [Default City]:.
Organization Name (eg, company) [Default Company Ltd]:.
Organizational Unit Name (eg, section) []:.
Common Name (eg, your name or your server's hostname) []:proxy.linux.tp6
Email Address []:.
[user1@proxy certs]$ ls
ssl_certificate.crt  ssl_certificate.key
```

```powershell
[user1@proxy conf.d]$ sudo cat tp6.conf 
[sudo] password for user1: 
server {
    listen 80;
    server_name web.tp6.linux;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name web.tp6.linux;
    ssl_certificate /etc/nginx/certs/ssl_certificate.crt;
    ssl_certificate_key /etc/nginx/certs/ssl_certificate.key;
    
	location / {
        # On définit des headers HTTP pour que le proxying se passe bien
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        # On définit la cible du proxying
        proxy_pass http://172.16.72.11:80;
    }

    # Deux sections location recommandés par la doc NextCloud
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }

    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
}
```

```powershell
[user1@proxy conf.d]$ sudo systemctl restart nginx
[user1@proxy conf.d]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
     Active: active (running) since Mon 2023-01-16 13:43:47 CET; 11s ago
    Process: 1282 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 1283 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 1284 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 1285 (nginx)
      Tasks: 2 (limit: 5878)
     Memory: 2.6M
        CPU: 26ms
     CGroup: /system.slice/nginx.service
             ├─1285 "nginx: master process /usr/sbin/nginx"
             └─1286 "nginx: worker process"

Jan 16 13:43:47 proxy.linux.tp6 systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jan 16 13:43:47 proxy.linux.tp6 nginx[1283]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jan 16 13:43:47 proxy.linux.tp6 nginx[1283]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Jan 16 13:43:47 proxy.linux.tp6 systemd[1]: Started The nginx HTTP and reverse proxy server.
```

```powershell
[user1@proxy conf.d]$ sudo firewall-cmd --add-port=443/tcp --permanent 
success
[user1@proxy conf.d]$ sudo firewall-cmd --reload
success
```

## Module 2 : Sauvegarde du système de fichiers 

1. Script du backup 

A et B) Ecriture du script 

```powershell
[user1@web srv]$ sudo dnf install rsync
[user1@web srv]$ sudo dnf install zip
```

```powershell
[user1@web srv]$ sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.16.72.12" port port="3306" protocol="tcp" accept'
success
[user1@web srv]$ sudo firewall-cmd --reload
success
```

```powershell
[user1@web srv]$ sudo mkdir backup
```

```powershell
[user1@web srv]$ sudo useradd backup -d /srv/backup/ -s /usr/bin/nologin -u 1999
useradd: Warning: missing or non-executable shell '/usr/bin/nologin'
useradd: warning: the home directory /srv/backup/ already exists.
useradd: Not copying any file from skel directory into it.
[user1@web srv]$ sudo chown backup /srv/backup/
[user1@web srv]$ ls -l
total 4
drwxr-xr-x. 2 backup root  43 Jan 17 20:08 backup
-rw-r--r--. 1 root   root 579 Jan 17 20:09 tp6_backup.sh
```

```powershell
[user1@web srv]$ sudo cat tp6_backup.sh 
#!/bin/bash

#Script written in January 2023 by Yohan Schenck
#It was created to save the main nextcloud files and database. 

backup_directory=/srv/backup/nextcloud-dirbkp_`date +"%Y%m%d"`


#Backup files
rsync -Aavx /var/www/tp5_nextcloud/ $backup_directory/

#Backup database
mysqldump --skip-column-statistics --single-transaction --default-character-set=utf8mb4 -h 172.16.72.12 -u nextcloud -ppewpewpew nextcloud > $backup_directory/nextcloud-sqlbkp_`date +"%Y%m%d"`.bak

#Zip folder
zip -r $backup_directory.zip $backup_directory

#Remove folder
rm -rf $backup_directory

```

C) Service et timer

* **Créer un service**

```powershell
[user1@web system]$ sudo cat backup.service 
[Unit]
Description=Backup service

[Service]
ExecStart=sh /srv/tp6_backup.sh
User=backup
Type=oneshot
```

```powershell
[user1@web system]$ sudo systemctl status backup.service 
○ backup.service - Backup service
     Loaded: loaded (/etc/systemd/system/backup.service; static)
     Active: inactive (dead)

Jan 17 20:55:57 web.linux.tp6 sh[1821]: apps/circles/lib/Search/LocalUsers.php
Jan 17 20:55:57 web.linux.tp6 sh[1821]: apps/circles/lib/Search/UnifiedSearchProvider.php
Jan 17 20:55:57 web.linux.tp6 sh[1821]: apps/circles/lib/Search/UnifiedSearchResult.php
Jan 17 20:55:57 web.linux.tp6 sh[1821]: apps/circles/lib/Service/
Jan 17 20:55:57 web.linux.tp6 sh[1821]: apps/circles/lib/Service/CircleService.php
Jan 17 20:55:57 web.linux.tp6 sh[1821]: apps/circles/lib/Service/CirclesService.php
Jan 17 20:55:57 web.linux.tp6 sh[1821]: apps/circles/lib/Service/ConfigService.php
Jan 17 20:56:16 web.linux.tp6 systemd[1]: backup.service: Deactivated successfully.
Jan 17 20:56:16 web.linux.tp6 systemd[1]: Finished Backup service.
Jan 17 20:56:16 web.linux.tp6 systemd[1]: backup.service: Consumed 13.510s CPU time.
```

* **Créer un timer**

```powershell
[user1@web system]$ sudo cat backup.timer 
[Unit]
Description=Run service X

[Timer]
OnCalendar=*-*-* 4:00:00

[Install]
WantedBy=timers.target
```

* **Activation du timer**

```powershell
[user1@web system]$ sudo systemctl daemon-reload
[user1@web system]$ sudo systemctl start backup.timer
[user1@web system]$ sudo systemctl enable backup.timer
Created symlink /etc/systemd/system/timers.target.wants/backup.timer → /etc/systemd/system/backup.timer.
[user1@web system]$ sudo systemctl status backup.timer
● backup.timer - Run service X
     Loaded: loaded (/etc/systemd/system/backup.timer; enabled; vendor preset: disabled)
     Active: active (waiting) since Tue 2023-01-17 21:09:40 CET; 21s ago
      Until: Tue 2023-01-17 21:09:40 CET; 21s ago
    Trigger: Wed 2023-01-18 04:00:00 CET; 6h left
   Triggers: ● backup.service

Jan 17 21:09:40 web.linux.tp6 systemd[1]: Started Run service X.
[user1@web system]$ sudo systemctl list-timers
NEXT                        LEFT          LAST                        PASSED       UNIT                         ACTIVATES                     
Tue 2023-01-17 21:52:35 CET 42min left    Tue 2023-01-17 20:47:06 CET 23min ago    dnf-makecache.timer          dnf-makecache.service
Wed 2023-01-18 00:00:00 CET 2h 49min left Tue 2023-01-17 19:47:22 CET 1h 23min ago logrotate.timer              logrotate.service
Wed 2023-01-18 04:00:00 CET 6h left       n/a                         n/a          backup.timer                 backup.service
Wed 2023-01-18 20:02:16 CET 22h left      Tue 2023-01-17 20:02:16 CET 1h 8min ago  systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service

4 timers listed.
Pass --all to see loaded but inactive timers, too.
```

2. NFS

A) Serveur NFS

* **Préparer un dossier à partager sur le réseau**

```powershell
[user1@storage ~]$ sudo mkdir /srv/nfs_shares
[sudo] password for user1: 
[user1@storage ~]$ sudo mkdir /srv/nfs_shares/web.tp6.linux/
```

* **Installer le serveur NFS**

```powershell
[user1@storage ~]$ sudo dnf install nfs-utils
[...]
Complete!
```

```powershell
[user1@storage ~]$ sudo chown nobody /srv/nfs_shares/web.tp6.linux/
```

```powershell
[user1@storage nfs_shares]$ sudo cat /etc/exports
/srv/nfs_shares/web.tp6.linux 172.16.72.11(rw,sync,no_subtree_check,no_root_squash)
```

```powershell
[user1@storage nfs_shares]$ sudo firewall-cmd --permanent --add-service=nfs
success
[user1@storage nfs_shares]$ sudo firewall-cmd --permanent --add-service=mountd
success
[user1@storage nfs_shares]$ firewall-cmd --permanent --add-service=rpc-bind
Authorization failed.
    Make sure polkit agent is running or run the application as superuser.
[user1@storage nfs_shares]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[user1@storage nfs_shares]$ sudo firewall-cmd --reload
success
[user1@storage nfs_shares]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s1 enp0s2
  sources: 
  services: cockpit dhcpv6-client mountd nfs rpc-bind ssh
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```

```powershell
[user1@storage nfs_shares]$ sudo systemctl enable nfs-server
[user1@storage nfs_shares]$ sudo systemctl start nfs-server
[user1@storage nfs_shares]$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; disabled; vendor preset: disabled)
     Active: active (exited) since Tue 2023-01-17 22:02:03 CET; 2s ago
    Process: 2276 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
    Process: 2277 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
    Process: 2289 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=exited, status=0/SUCCESS)
   Main PID: 2289 (code=exited, status=0/SUCCESS)
        CPU: 20ms

Jan 17 22:02:03 storage.tp6.linux systemd[1]: Starting NFS server and services...
Jan 17 22:02:03 storage.tp6.linux systemd[1]: Finished NFS server and services.
```



B) Client NFS

* **Installez un client NFS**

```powershell
[user1@web system]$ sudo dnf install nfs-utils
[...]
Complete!
```

```powershell
[user1@web system]$ sudo mount 172.16.72.19:/srv/nfs_shares/web.tp6.linux/ /srv/backup/
[user1@web system]$ df -h | grep tp6
172.16.72.19:/srv/nfs_shares/web.tp6.linux  5.6G  1.2G  4.5G  21% /srv/backup
```

```powershell
[user1@web srv]$ sudo cat /etc/fstab | grep tp6
172.16.72.19:/srv/nfs_shares/web.tp6.linux /srv/backup nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
```

* **Tester la restauration des données**

```powershell
[user1@web backup]$ sudo unzip nextcloud-dirbkp_20230117.zip
```

```powershell
[user1@web nextcloud-dirbkp_20230117]$ sudo mv nextcloud-sqlbkp_20230117.bak /srv/backup/
[user1@web backup]$ sudo mv nextcloud-dirbkp_20230117/ /srv/backup/
```

```powershell
[user1@web backup]$ sudo rsync -Aax nextcloud-dirbkp_20230117 nextcloud/
```

```powershell
[user1@web backup]$ mysql -h 172.16.72.12 -u nextcloud -ppewpewpew -e "DROP DATABASE nextcloud"
mysql: [Warning] Using a password on the command line interface can be insecure.
[user1@web backup]$ mysql -h 172.16.72.12 -u nextcloud -ppewpewpew -e "CREATE DATABASE nextcloud"
mysql: [Warning] Using a password on the command line interface can be insecure.
[user1@web backup]$ mysql -h 172.16.72.12 -u nextcloud -ppewpewpew nextcloud < nextcloud-sqlbkp_20230117.bak 
mysql: [Warning] Using a password on the command line interface can be insecure.
```

## Module 3 : Fail2Ban

A) Installer Netdata

```powershell
[user1@db ~]$ sudo dnf install epel-release
[user1@db ~]$ sudo dnf install fail2ban fail2ban-firewalld
```
```powershell
[user1@db ~]$ sudo systemctl start fail2ban
[user1@db ~]$ sudo systemctl status fail2ban
● fail2ban.service - Fail2Ban Service
     Loaded: loaded (/usr/lib/systemd/system/fail2ban.service; disabled; vendor preset: disabled)
     Active: active (running) since Wed 2023-01-18 00:35:09 CET; 7s ago
       Docs: man:fail2ban(1)
    Process: 12584 ExecStartPre=/bin/mkdir -p /run/fail2ban (code=exited, status=0/SUCCESS)
   Main PID: 12585 (fail2ban-server)
      Tasks: 3 (limit: 5877)
     Memory: 10.3M
        CPU: 60ms
     CGroup: /system.slice/fail2ban.service
             └─12585 /usr/bin/python3 -s /usr/bin/fail2ban-server -xf start

Jan 18 00:35:08 db.linux.tp6 systemd[1]: Starting Fail2Ban Service...
Jan 18 00:35:09 db.linux.tp6 systemd[1]: Started Fail2Ban Service.
Jan 18 00:35:09 db.linux.tp6 fail2ban-server[12585]: 2023-01-18 00:35:09,059 fail2ban.configreader   [12585]: WARNING 'allowipv6' not defined in 'Definition'. Using default one: 'auto'
Jan 18 00:35:09 db.linux.tp6 fail2ban-server[12585]: Server ready
[user1@db ~]$ sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
[user1@db ~]$ sudo mv /etc/fail2ban/jail.d/00-firewalld.conf /etc/fail2ban/jail.d/00-firewalld.local
[user1@db ~]$ sudo systemctl restart fail2ban
```

```powershell
[user1@db ~]$ sudo cat /etc/fail2ban/jail.d/sshd.local
[sshd]
enabled = true

# Override the default global configuration
# for specific jail sshd
bantime = 1d
maxretry = 3
findtime = 1m
[user1@db ~]$ sudo systemctl restart fail2ban
[user1@db ~]$ sudo fail2ban-client get sshd maxretry
3
[user1@db ~]$ sudo fail2ban-client get sshd findtime
60
[user1@db ~]$ sudo fail2ban-client status
Status
|- Number of jail:	1
`- Jail list:	sshd
[user1@db ~]$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed:	0
|  |- Total failed:	3
|  `- Journal matches:	_SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned:	1
   |- Total banned:	1
   `- Banned IP list:	172.16.72.11
[user1@db ~]$ sudo firewall-cmd --list-all | grep rule
  rich rules: 
	rule family="ipv4" source address="172.16.72.11" port port="ssh" protocol="tcp" reject type="icmp-port-unreachable"
[user1@db ~]$ sudo fail2ban-client unban 172.16.72.11
1
[user1@db ~]$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed:	0
|  |- Total failed:	0
|  `- Journal matches:	_SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned:	0
   |- Total banned:	1
   `- Banned IP list:	
```

## Module 4 : Monitoring


```powershell
[user1@web backup]$ sudo dnf install wget
[user1@web backup]$ sudo wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && sh /tmp/netdata-kickstart.sh
```

```powershell
[user1@web backup]$ sudo systemctl start netdata
[user1@web backup]$ systemctl status netdata
● netdata.service - Real time performance monitoring
     Loaded: loaded (/usr/lib/systemd/system/netdata.service; enabled; vendor preset: disabled)
     Active: active (running) since Wed 2023-01-18 02:03:11 CET; 1min 39s ago
   Main PID: 4166 (netdata)
      Tasks: 59 (limit: 4206)
     Memory: 82.3M
        CPU: 4.460s
     CGroup: /system.slice/netdata.service
             ├─4166 /usr/sbin/netdata -P /run/netdata/netdata.pid -D
             ├─4168 /usr/sbin/netdata --special-spawn-server
             ├─4381 bash /usr/libexec/netdata/plugins.d/tc-qos-helper.sh 1
             ├─4394 /usr/libexec/netdata/plugins.d/apps.plugin 1
             └─4396 /usr/libexec/netdata/plugins.d/go.d.plugin 1

Jan 18 02:03:11 web.linux.tp6 systemd[1]: Starting Real time performance monitoring...
Jan 18 02:03:11 web.linux.tp6 systemd[1]: Started Real time performance monitoring.
Jan 18 02:03:11 web.linux.tp6 netdata[4166]: CONFIG: cannot load cloud config '/var/lib/netdata/cloud.d/cloud.conf'. Running with internal defaults.
Jan 18 02:03:11 web.linux.tp6 netdata[4166]: 2023-01-18 02:03:11: netdata INFO  : MAIN : CONFIG: cannot load cloud config '/var/lib/netdata/cloud.d/cloud.conf'. Running with internal defaults.
Jan 18 02:03:11 web.linux.tp6 netdata[4166]: Found 0 legacy dbengines, setting multidb diskspace to 256MB
Jan 18 02:03:11 web.linux.tp6 netdata[4166]: 2023-01-18 02:03:11: netdata INFO  : MAIN : Found 0 legacy dbengines, setting multidb diskspace to 256MB
Jan 18 02:03:11 web.linux.tp6 netdata[4166]: Created file '/var/lib/netdata/dbengine_multihost_size' to store the computed value
Jan 18 02:03:11 web.linux.tp6 netdata[4166]: 2023-01-18 02:03:11: netdata INFO  : MAIN : Created file '/var/lib/netdata/dbengine_multihost_size' to store the computed value
```

```powershell
[user1@web backup]$ sudo firewall-cmd --permanent --add-port=19999/tcp
success
[user1@web backup]$ sudo firewall-cmd --reload
success
```

```powershell
[user1@web backup]$ ss -lapten | grep netdata                         
LISTEN    0      4096              0.0.0.0:19999            0.0.0.0:*     uid:989 ino:45722 sk:5 cgroup:/system.slice/netdata.service <-> 
```

B) Une fois Netdata installé et fonctionnel, déterminer 

```powershell
[user1@web backup]$ ps -ef | grep netdata
netdata     4166       1  1 02:03 ?        00:00:09 /usr/sbin/netdata -P /run/netdata/netdata.pid -D
netdata     4168    4166  0 02:03 ?        00:00:00 /usr/sbin/netdata --special-spawn-server
netdata     4381    4166  0 02:03 ?        00:00:00 bash /usr/libexec/netdata/plugins.d/tc-qos-helper.sh 1
netdata     4394    4166  1 02:03 ?        00:00:05 /usr/libexec/netdata/plugins.d/apps.plugin 1
netdata     4396    4166  0 02:03 ?        00:00:02 /usr/libexec/netdata/plugins.d/go.d.plugin 1
```

```powershell
[user1@web backup]$ ss -lapten | grep netdata
LISTEN    0      4096            127.0.0.1:8125             0.0.0.0:*     uid:989 ino:46705 sk:4 cgroup:/system.slice/netdata.service <->                              
LISTEN    0      4096              0.0.0.0:19999            0.0.0.0:*     uid:989 ino:45722 sk:5 cgroup:/system.slice/netdata.service <->                              
ESTAB     0      0            172.16.72.11:19999        172.16.72.1:53094 timer:(keepalive,114min,0) uid:989 ino:52220 sk:54 cgroup:/system.slice/netdata.service <->  
ESTAB     0      0               127.0.0.1:38372          127.0.0.1:80    timer:(keepalive,2.450ms,0) uid:989 ino:56662 sk:11e cgroup:/system.slice/netdata.service <->
LISTEN    0      4096                [::1]:8125                [::]:*     uid:989 ino:46704 sk:86 cgroup:/system.slice/netdata.service v6only:1 <->                    
LISTEN    0      4096                 [::]:19999               [::]:*     uid:989 ino:45723 sk:87 cgroup:/system.slice/netdata.service v6only:1 <->                    
ESTAB     0      0                   [::1]:46368              [::1]:80    timer:(keepalive,450ms,0) uid:989 ino:56642 sk:126 cgroup:/system.slice/netdata.service <-> 
```

```powershell
[user1@web backup]$ sudo journalctl -xe -u netdata -f
Jan 18 02:03:11 web.linux.tp6 systemd[1]: Starting Real time performance monitoring...
░░ Subject: A start job for unit netdata.service has begun execution
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░ 
░░ A start job for unit netdata.service has begun execution.
░░ 
░░ The job identifier is 2981.
Jan 18 02:03:11 web.linux.tp6 systemd[1]: Started Real time performance monitoring.
░░ Subject: A start job for unit netdata.service has finished successfully
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░ 
░░ A start job for unit netdata.service has finished successfully.
░░ 
░░ The job identifier is 2981.
Jan 18 02:03:11 web.linux.tp6 netdata[4166]: CONFIG: cannot load cloud config '/var/lib/netdata/cloud.d/cloud.conf'. Running with internal defaults.
Jan 18 02:03:11 web.linux.tp6 netdata[4166]: 2023-01-18 02:03:11: netdata INFO  : MAIN : CONFIG: cannot load cloud config '/var/lib/netdata/cloud.d/cloud.conf'. Running with internal defaults.
Jan 18 02:03:11 web.linux.tp6 netdata[4166]: Found 0 legacy dbengines, setting multidb diskspace to 256MB
Jan 18 02:03:11 web.linux.tp6 netdata[4166]: 2023-01-18 02:03:11: netdata INFO  : MAIN : Found 0 legacy dbengines, setting multidb diskspace to 256MB
Jan 18 02:03:11 web.linux.tp6 netdata[4166]: Created file '/var/lib/netdata/dbengine_multihost_size' to store the computed value
Jan 18 02:03:11 web.linux.tp6 netdata[4166]: 2023-01-18 02:03:11: netdata INFO  : MAIN : Created file '/var/lib/netdata/dbengine_multihost_size' to store the computed value
```

C) Configurer Netdata pour qu'il vous envoie des alertes

```powershell
[user1@web netdata]$ sudo cat /etc/netdata/health_alarm_notify.conf 
###############################################################################
# sending discord notifications

# note: multiple recipients can be given like this:
#                  "CHANNEL1 CHANNEL2 ..."

# enable/disable sending discord notifications
SEND_DISCORD="YES"

# Create a webhook by following the official documentation -
# https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1065194940486926376/1qS6MY4-RWJlT6UW_0j2XO_d0SCacO29HGgGJGErnBF8jIijFinzvDTjbcD4yVM4YUYW"

# if a role's recipients are not configured, a notification will be send to
# this discord channel (empty = do not send a notification for unconfigured
# roles):
DEFAULT_RECIPIENT_DISCORD="alert"
```

D) Vérifier que les alertes fonctionnent

```powershell
[user1@web backup]$ sudo dnf install stress
```
```powershell
[user1@web netdata]$ sudo cat health.d/cpu.conf | head -n 10

# you can disable an alarm notification by setting the 'to' line to: silent

 template: 10min_cpu_usage
       on: system.cpu
    class: Utilization
     type: System
component: CPU
       os: linux
    hosts: *
```

```powershell
[user1@web netdata]$ sudo cat health.d/cpu_usage.conf 
alarm: cpu_usage
on: system.cpu
lookup : average -3s percentage foreach user,system
units: %
every: 10s
warn: $this > 50
crit: $this > 80
```

```powershell
[user1@web netdata]$ sudo stress --cpu 8 --io 4 --vm 2 --vm-bytes 128M --timeout 10s
```













