# TP2 : Appréhender l'environnement Linux

## I) Service SSH
----

1. Analyse du service 

A) S'assurer que le service sshd est démarré

```powershell
[user1@VM-Linux-2 ~]$ systemctl status | grep sshd
           │ ├─sshd.service
           │ │ └─640 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"
               │ ├─805 "sshd: user1 [priv]"
               │ ├─809 "sshd: user1@pts/0"
               │ └─847 grep --color=auto sshd
```

B) Analyser les processus liés au service SSH

```powershell
[user1@VM-Linux-2 ~]$ ps -ef | grep ssdh
user1        850     810  0 11:20 pts/0    00:00:00 grep --color=auto ssdh
```

C) Déterminer le port sur lequel écoute le service SSH

```powershell
[user1@VM-Linux-2 ~]$ sudo ss -alnpt | grep ssh
LISTEN 0      128          0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=640,fd=3))
LISTEN 0      128             [::]:22           [::]:*    users:(("sshd",pid=640,fd=4))
```

**Port 22**

D) Consulter les logs du service SSH

* Commande journalctl

```powershell
[user1@VM-Linux-2 ~]$ journalctl -xe -u sshd -f
Dec 05 11:09:58 VM-Linux-2 systemd[1]: Starting OpenSSH server daemon...
░░ Subject: A start job for unit sshd.service has begun execution
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░ 
░░ A start job for unit sshd.service has begun execution.
░░ 
░░ The job identifier is 238.
Dec 05 11:09:58 VM-Linux-2 sshd[640]: Server listening on 0.0.0.0 port 22.
Dec 05 11:09:58 VM-Linux-2 sshd[640]: Server listening on :: port 22.
Dec 05 11:09:58 VM-Linux-2 systemd[1]: Started OpenSSH server daemon.
░░ Subject: A start job for unit sshd.service has finished successfully
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░ 
░░ A start job for unit sshd.service has finished successfully.
░░ 
░░ The job identifier is 238.
Dec 05 11:10:12 VM-Linux-2 sshd[805]: Accepted password for user1 from 192.168.64.1 port 59439 ssh2
Dec 05 11:10:12 VM-Linux-2 sshd[805]: pam_unix(sshd:session): session opened for user user1(uid=1000) by (uid=0)
```

* Commande tail 

```powershell
[user1@VM-Linux-2 log]$ sudo tail -n 10 secure 
Dec  5 11:23:01 VM-Linux-2 sudo[863]: pam_unix(sudo:session): session closed for user root
Dec  5 11:31:25 VM-Linux-2 sudo[880]:   user1 : TTY=pts/0 ; PWD=/var/log ; USER=root ; COMMAND=/bin/tail -n 10 secure
Dec  5 11:31:25 VM-Linux-2 sudo[880]: pam_unix(sudo:session): session opened for user root(uid=0) by user1(uid=1000)
Dec  5 11:31:25 VM-Linux-2 sudo[880]: pam_unix(sudo:session): session closed for user root
Dec  5 11:32:55 VM-Linux-2 sudo[885]:   user1 : TTY=pts/0 ; PWD=/var/log ; USER=root ; COMMAND=/bin/tail -n 20 secure
Dec  5 11:32:55 VM-Linux-2 sudo[885]: pam_unix(sudo:session): session opened for user root(uid=0) by user1(uid=1000)
Dec  5 11:32:55 VM-Linux-2 sudo[885]: pam_unix(sudo:session): session closed for user root
Dec  5 11:33:46 VM-Linux-2 sudo[888]:   user1 : TTY=pts/0 ; PWD=/var/log ; USER=root ; COMMAND=/bin/tail -n 30 secure
Dec  5 11:33:46 VM-Linux-2 sudo[888]: pam_unix(sudo:session): session opened for user root(uid=0) by user1(uid=1000)
Dec  5 11:33:46 VM-Linux-2 sudo[888]: pam_unix(sudo:session): session closed for user root
```

2. Modification du service 

A) Identifier le fichier de configuration du serveur SSH

```powershell
[user1@VM-Linux-2 ssh]$ sudo vim sshd_config
```



B) Modifier le fichier de conf 

```powershell
[user1@VM-Linux-2 ssh]$ echo $RANDOM
3571
```

```powershell
[user1@VM-Linux-2 ssh]$ sudo cat sshd_config | grep Port
#Port 3571
```

```powershell
[user1@VM-Linux-2 ssh]$ sudo firewall-cmd --list-all | grep 3571
  ports: 3571/tcp
```

C) Redémarrer le service

```powershell
[user1@VM-Linux-2 ssh]$ systemctl restart sshd
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ====
Authentication is required to restart 'sshd.service'.
Authenticating as: user1
Password: 
==== AUTHENTICATION COMPLETE ====
```

D) Effectuer une connexion SSH sur le nouveau port 

```powershell
MacBook-Air-Yohan:~ yohan$ ssh user1@192.168.64.6 -p 3571
user1@192.168.64.6's password: 
Last login: Mon Dec  5 12:05:28 2022 from 192.168.64.1
[user1@VM-Linux-2 ~]$ 
```


## II) Service HTTP
---

1. Mise en place 

A) Installer le serveur NGINX

```powershell
[user1@VM-Linux-2 ~]$ sudo dnf install nginx
[sudo] password for user1: 
Last metadata expiration check: 0:34:38 ago on Mon 05 Dec 2022 11:47:27 AM CET.
Dependencies resolved.
...
Complete!
```

B) Démarrer le service NGINX

```powershell
[user1@VM-Linux-2 ~]$ sudo systemctl enable nginx
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
[user1@VM-Linux-2 ~]$ sudo systemctl start nginx
```

C) Déterminer sur quel port tourne NGINX

```powershell
[user1@VM-Linux-2 ~]$ sudo ss -alnpt | grep nginx
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=11280,fd=6),("nginx",pid=11279,fd=6))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=11280,fd=7),("nginx",pid=11279,fd=7))
```

**Port 80**

```powershell
[user1@VM-Linux-2 ~]$ sudo firewall-cmd --permanent --add-service=http
success
[user1@VM-Linux-2 ~]$ sudo firewall-cmd --permanent --list-all | grep http
  services: cockpit dhcpv6-client http ssh
```

D) Déterminer les processus liés à l'exécution de NGINX

```powershell
[user1@VM-Linux-2 ~]$ ps -ef | grep http
user1      11299    1300  0 12:33 pts/0    00:00:00 grep --color=auto http
```

E) Euh wait

```powershell
MacBook-Air-Yohan:~ yohan$ curl 172.16.72.11 | head -n 7
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0   542k      0 --:--:-- --:--:-- --:--:-- 1063k
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
```


2. Analyser la conf de NGINX

A) Déterminer le path du fichier de confifuration de NGINX

```powershell
[user1@VM-Linux-2 nginx]$ ls -al /etc/nginx/nginx.conf
-rw-r--r--. 1 root root 2334 Oct 31 16:37 /etc/nginx/nginx.conf
```

B) Trouver dans le fichier de conf

```powershell
[user1@VM-Linux-2 nginx]$ cat nginx.conf | grep server -A 10
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

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
[user1@VM-Linux-2 nginx]$ cat nginx.conf | grep include
  include /usr/share/nginx/modules/*.conf;
  include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/default.d/*.conf;
```

3. Déployer un nouveau site web 

A) Créer un site web

```powershell
[user1@VM-Linux-2 tp2_linux]$ cat index.html 
<h1>MEOW mon premier serveur web</h1>
```

B) Adapter la conf NGINX


```powershell
[user1@VM-Linux-2 nginx]$ cat nginx.conf
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
[user1@VM-Linux-2 nginx]$ systemctl restart nginx
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ====
Authentication is required to restart 'nginx.service'.
Authenticating as: user1
Password: 
==== AUTHENTICATION COMPLETE ====
```

```powershell
[user1@VM-Linux-2 conf.d]$ cat nginx.conf 
server {
  # le port choisi devra être obtenu avec un 'echo $RANDOM' là encore
  listen 29786;

  root /var/www/tp2_linux;
}
```

```powershell
[user1@VM-Linux-2 conf.d]$ systemctl restart nginx
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ====
Authentication is required to restart 'nginx.service'.
Authenticating as: user1
Password: 
==== AUTHENTICATION COMPLETE ====
```

```powershell
[user1@VM-Linux-2 tp2_linux]$ sudo firewall-cmd --add-port=29786/tcp --permanent
success
[user1@VM-Linux-2 tp2_linux]$ sudo firewall-cmd --reload
success
```


C) Visitez votre super site web


```powershell
MacBook-Air-Yohan:~ yohan$ curl http://172.16.72.11:29786
<h1>MEOW mon premier serveur web</h1>
```

## III) Your own services
---


2. Analyse des services existants

A) Afficher le fichier de service SSh

```powershell
[user1@VM-Linux-2 tp2_linux]$ cat /usr/lib/systemd/system/sshd.service | grep ExecStart=
ExecStart=/usr/sbin/sshd -D $OPTIONS
```

B) Afficher le fichier de service NGINX

```powershell
[user1@VM-Linux-2 tp2_linux]$ cat /usr/lib/systemd/system/nginx.service | grep ExecStart=
ExecStart=/usr/sbin/nginx
```

3. Création de service 

A) Créez le fichier /etc/systemd/system/tp2_nc.service

```powershell
[user1@VM-Linux-2 tp2_linux]$ cat /etc/systemd/system/tp2_nc.service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 1277
```

B) Indiquer au système qu'on a modifié les fichiers de service

```powershell
[user1@VM-Linux-2 tp2_linux]$ sudo systemctl daemon-reload
```

C) Démarrer notre service de ouf 

```powershell
[user1@VM-Linux-2 tp2_linux]$ systemctl start tp2_nc
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ====
Authentication is required to start 'tp2_nc.service'.
Authenticating as: user1
Password: 
==== AUTHENTICATION COMPLETE ====
```

D) Vérifier que ca fonctionne

```powershell
[user1@VM-Linux-2 tp2_linux]$ systemctl status tp2_nc.service
● tp2_nc.service - Super netcat tout fou
     Loaded: loaded (/usr/lib/systemd/system/tp2_nc.service; static)
     Active: active (running) since Mon 2022-12-05 14:39:54 CET; 5s ago
   Main PID: 11838 (nc)
      Tasks: 1 (limit: 5878)
     Memory: 728.0K
        CPU: 4ms
     CGroup: /system.slice/tp2_nc.service
             └─11838 /usr/bin/nc -l 1277

Dec 05 14:39:54 VM-Linux-2 systemd[1]: Started Super netcat tout fou.
```

```powershell
er1@VM-Linux-2 tp2_linux]$ ss -lapt | grep 1277
LISTEN 0      10           0.0.0.0:1277      0.0.0.0:*           
LISTEN 0      10              [::]:1277         [::]:* 
```

```powershell
[user1@VM-Linux-2 tp2_linux]$ sudo firewall-cmd --add-port=1277/tcp --permanent
success
[user1@VM-Linux-2 tp2_linux]$ sudo firewall-cmd --reload
success
```

```powershell
[user1@localhost ~]$ nc 172.16.72.11 1277
lol
Yo
```

E) Les logs de votre service 

```powershell
[user1@VM-Linux-2 tp2_linux]$ sudo journalctl -xe -u tp2_nc | grep Started
Dec 05 15:05:47 VM-Linux-2 systemd[1]: Started Super netcat tout fou.
```

```powershell
[user1@VM-Linux-2 tp2_linux]$ sudo journalctl -xe -u tp2_nc | grep  12280
Dec 05 15:12:14 VM-Linux-2 nc[12280]: lol
Dec 05 15:13:59 VM-Linux-2 nc[12280]: Yo
```

```powershell
[user1@VM-Linux-2 tp2_linux]$ sudo journalctl -xe -u tp2_nc | grep  Stopped
Dec 05 15:05:47 VM-Linux-2 systemd[1]: Stopped Super netcat tout fou.
```


F) Affiner la définiton du service 

```powershell
[user1@VM-Linux-2 tp2_linux]$ sudo  cat /etc/systemd/system/tp2_nc.service 
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 1277
Restart=always
````



 


