# TP 5 : Self-hosted cloud

## Partie 1 : Mise en place et maîtrise du serveur Web
---
1. Installation

A) Installer le serveur Apache

* Paquet httpd

```powershell
[user1@web ~]$ sudo dnf install httpd
[sudo] password for user1: 
[...]
Installed:
  apr-1.7.0-11.el9.aarch64              apr-util-1.6.1-20.el9.aarch64              apr-util-bdb-1.6.1-20.el9.aarch64       apr-util-openssl-1.6.1-20.el9.aarch64       httpd-2.4.53-7.el9.aarch64           
  httpd-core-2.4.53-7.el9.aarch64       httpd-filesystem-2.4.53-7.el9.noarch       httpd-tools-2.4.53-7.el9.aarch64        mailcap-2.1.49-5.el9.noarch                 mod_http2-1.15.19-2.el9.aarch64      
  mod_lua-2.4.53-7.el9.aarch64          rocky-logos-httpd-90.13-1.el9.noarch      

Complete!
```

2. Démarrer le service Apache 

```powershell
[user1@web ~]$ sudo systemctl start httpd 
[user1@web ~]$ sudo systemctl status httpd 
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
     Active: active (running) since Fri 2023-01-06 19:38:01 CET; 5s ago
       Docs: man:httpd.service(8)
   Main PID: 11272 (httpd)
     Status: "Started, listening on: port 80"
      Tasks: 213 (limit: 5878)
     Memory: 22.1M
        CPU: 63ms
     CGroup: /system.slice/httpd.service
             ├─11272 /usr/sbin/httpd -DFOREGROUND
             ├─11282 /usr/sbin/httpd -DFOREGROUND
             ├─11283 /usr/sbin/httpd -DFOREGROUND
             ├─11284 /usr/sbin/httpd -DFOREGROUND
             └─11285 /usr/sbin/httpd -DFOREGROUND

Jan 06 19:37:21 web.linux.tp5 systemd[1]: Starting The Apache HTTP Server...
Jan 06 19:38:01 web.linux.tp5 systemd[1]: Started The Apache HTTP Server.
Jan 06 19:38:01 web.linux.tp5 httpd[11272]: Server configured, listening on: port 80
```

```powershell
[user1@web ~]$ sudo systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
```

```powershell
[[user1@web conf]$ ss -lapten | grep httpd
LISTEN 0      511                *:80            *:*     ino:37438 sk:34 cgroup:/system.slice/httpd.service v6only:0 <->          
```

```powershell
[user1@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[user1@web ~]$ sudo firewall-cmd --reload
success
[user1@web ~]$ sudo firewall-cmd --list-all | grep 80
  ports: 80/tcp
```

C) Test

```powershell
[user1@web ~]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
     Active: active (running) since Fri 2023-01-06 19:38:01 CET; 10min ago
       Docs: man:httpd.service(8)
   Main PID: 11272 (httpd)
     Status: "Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:   0 B/sec"
      Tasks: 213 (limit: 5878)
     Memory: 22.2M
        CPU: 889ms
     CGroup: /system.slice/httpd.service
             ├─11272 /usr/sbin/httpd -DFOREGROUND
             ├─11282 /usr/sbin/httpd -DFOREGROUND
             ├─11283 /usr/sbin/httpd -DFOREGROUND
             ├─11284 /usr/sbin/httpd -DFOREGROUND
             └─11285 /usr/sbin/httpd -DFOREGROUND

Jan 06 19:37:21 web.linux.tp5 systemd[1]: Starting The Apache HTTP Server...
Jan 06 19:38:01 web.linux.tp5 systemd[1]: Started The Apache HTTP Server.
Jan 06 19:38:01 web.linux.tp5 httpd[11272]: Server configured, listening on: port 80
```

```powershell
[user1@web ~]$ sudo systemctl is-enabled httpd
enabled
```

```powershell
[user1@web ~]$ curl localhost | head -n 10
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/
      
      html {
100  7620  100  7620    0     0   826k      0 --:--:-- --:--:-- --:--:--  826k
curl: (23) Failed writing body
````

**curl réalisé depuis un train ce qui entraîne le "curl : (23)Failed writing body"**

```powershell
MacBook-Air-Yohan:~ yohan$ curl 172.16.72.11 | head -n 10
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0   716k      0 --:--:-- --:--:-- --:--:-- 1488k
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

2. Avancer vers la maîtrise du service 

A) Le service Apache 

```powershell
[user1@web ~]$ sudo cat /usr/lib/systemd/system/httpd.service
# See httpd.service(8) for more information on using the httpd service.

# Modifying this file in-place is not recommended, because changes
# will be overwritten during package upgrades.  To customize the
# behaviour, run "systemctl edit httpd" to create an override unit.

# For example, to pass additional options (such as -D definitions) to
# the httpd binary at startup, create an override unit (as is done by
# systemctl edit) and enter the following:

#	[Service]
#	Environment=OPTIONS=-DMY_DEFINE

[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
OOMPolicy=continue

[Install]
WantedBy=multi-user.target
```

B) Déterminer sous quel utilisateur tourne le processus Apache

```powershell
[user1@web ~]$ sudo cat /etc/httpd/conf/httpd.conf | grep User 
User apache
```

```powershell
[user1@web ~]$ ps -ef | grep apache
apache     11282   11272  0 19:38 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```

```powershell
[user1@web testpage]$ ls -al
total 12
drwxr-xr-x.  2 root root   24 Jan  6 19:04 .
drwxr-xr-x. 85 root root 4096 Jan  6 19:04 ..
-rw-r--r--.  1 root root 7620 Jul 27 20:05 index.html
```

**Read for other users**

C) Changer l'utilisateur utilisé par Apache


* Créer un nouvel utilisateur 

```powershell
[user1@web testpage]$ sudo cat /etc/passwd | tail -n 2
apache:x:48:48:Apache:/usr/share/httpd:/sbin/nologin
web:x:1001:1001::/usr/share/httpd/:/sbin/nologin
```

* Modification du fichier .conf

```powershell
[user1@web testpage]$ sudo cat /etc/httpd/conf/httpd.conf | grep User
User web
```

* Redémarrage du service 

```powershell
[user1@web testpage]$ sudo systemctl restart httpd
```

```powershell
[user1@web testpage]$ ps -ef | grep httpd
root       11738       1  0 21:17 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
web        11741   11738  0 21:17 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
web        11742   11738  0 21:17 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
web        11743   11738  0 21:17 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
web        11744   11738  0 21:17 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```

D) Faites en sorte que Apache tourne sur un autre port

* Modification du fichier .conf

```powershell
[user1@web testpage]$ sudo cat /etc/httpd/conf/httpd.conf | grep Listen
Listen 8080
```

* Ouverture/Fermeture des ports 

```powershell
[user1@web testpage]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
```

```powershell
[user1@web testpage]$ sudo firewall-cmd --add-port=8080/tcp --permanent
success
[user1@web testpage]$ sudo firewall-cmd --reload
success
[user1@web testpage]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s1 enp0s2
  sources: 
  services: cockpit dhcpv6-client ssh
  ports: 8080/tcp
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```

* Redémarrage du service 

```powershell
[user1@web conf]$ sudo systemctl restart httpd
```

* Commande ss

```powershell
[[user1@web conf]$ ss -lapten | grep httpd
LISTEN 0      511                *:8080            *:*     ino:37438 sk:34 cgroup:/system.slice/httpd.service v6only:0 <->       
```

* Curl

```powershell
MacBook-Air-Yohan:~ yohan$ curl 172.16.72.11:8080 | head -n 10
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0   668k      0 --:--:-- --:--:-- --:--:-- 1240k
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

## Partie 2 : Mise en place et maîtrise du serveur de base de données
---

A) Install de MariaDB sur db.tp5.linux

```powershell
[user1@db ~]$ sudo dnf install mariadb-server
[...]
Complete!
```

```powershell
[user1@db ~]$ sudo systemctl enable mariadb
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.
```

```powershell
[user1@db ~]$ sudo systemctl start mariadb
```

```powershell
[user1@db ~]$ sudo mysql_secure_installation
```

```powershell
[user1@db ~]$ sudo systemctl is-enabled mariadb
enabled
```

B) Port utilisé par MariaDB

```powershell
[user1@db ~]$ ss -lapten | grep mariadb
LISTEN 0      80                 *:3306            *:*     uid:27 ino:36842 sk:4 cgroup:/system.slice/mariadb.service v6only:0 <->  
```


```powershell
[user1@db ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent
[sudo] password for user1: 
success
[user1@db ~]$ sudo firewall-cmd --reload
success
[user1@db ~]$ sudo firewall-cmd --list-all | grep ports
  ports: 3306/tcp
```

C) Processus liés à MariaDB

```powershell
[user1@db ~]$ ps -ef | grep mariadb
mysql      13015       1  0 21:42 ?        00:00:01 /usr/libexec/mariadbd --basedir=/usr
```

## Partie 3 : Configuration et mise en place de NextCloud
---

1. Base de données 

A) Préparation de la base pour NextCloud

```powershell
[user1@db ~]$ sudo mysql -u root -p
MariaDB [(none)]> CREATE USER 'nextcloud'@'172.16.72.11' IDENTIFIED BY 'pewpewpew';
Query OK, 0 rows affected (0.008 sec)

MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.001 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'172.16.72.11';
Query OK, 0 rows affected (0.004 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.002 sec)
```

B) Exploration de la base de données 

```powershell
[user1@web conf]$ sudo dnf install mysql
[...]
Complete!
```

```powershell
[user1@web conf]$ mysql -u nextcloud -h 172.16.72.12 -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 27
Server version: 5.5.5-10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
```

```powershell
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.01 sec)

mysql> USE nextcloud;
Database changed
mysql> show tables;
Empty set (0.00 sec)
```


C) Trouver une commande SQL qui permet de lister tous les utilisateurs de la bse de données 

```powershell
MariaDB [(none)]> SELECT user FROM mysql.user;
+-------------+
| User        |
+-------------+
| nextcloud   |
| mariadb.sys |
| mysql       |
| root        |
+-------------+
4 rows in set (0.012 sec)
```

2. Serveur Web et NextCloud

* Réinitialisation de la conf apache 

```powershell
[user1@web conf]$ sudo cat httpd.conf | head -n 10

ServerRoot "/etc/httpd"

Listen 80

Include conf.modules.d/*.conf

User apache
Group apache

[user1@web conf]$ ps -ef | grep httpd
root       12581       1  0 01:09 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache     12584   12581  0 01:09 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache     12585   12581  0 01:09 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache     12586   12581  0 01:09 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache     12587   12581  0 01:09 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
[user1@web conf]$ ss -lapten | grep httpd
LISTEN 0      511                *:80              *:*     ino:41155 sk:35 cgroup:/system.slice/httpd.service v6only:0 <->                
[user1@web conf]$ sudo firewall-cmd --remove-port=8080/tcp --permanent
success
[user1@web conf]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[user1@web conf]$ sudo firewall-cmd --reload
success
[user1@web conf]$ sudo firewall-cmd --list-all
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
MacBook-Air-Yohan:~ yohan$ curl 172.16.72.11 | head -n 10
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0   620k      0 --:--:-- --:--:-- --:--:-- 1063k
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

A) Install de PHP

```powershell
[user1@web conf]$ sudo dnf config-manager --set-enabled crb
[sudo] password for user1:
[user1@web conf]$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
[...]
Complete!
[user1@web conf]$ dnf module list php
[...]
Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
[user1@web conf]$ sudo dnf module enable php:remi-8.1 -y
[...]
Comlete!
[user1@web conf]$ sudo dnf install -y php
[...]
Complete!
[user1@web conf]$ php --version
PHP Warning:  PHP Startup: ^(text/|application/xhtml\+xml) (offset=0): unrecognised compile-time option bit(s) in Unknown on line 0
PHP 8.1.14 (cli) (built: Jan  4 2023 06:45:14) (NTS gcc aarch64)
Copyright (c) The PHP Group
Zend Engine v4.1.14, Copyright (c) Zend Technologies
    with Zend OPcache v8.1.14, Copyright (c), by Zend Technologies
```

B) Install de tous les modules PHP nécessaires pour NextCloud

* Nom de paquet différent

```powershell
[user1@web ~]$ cat i
libxml2
openssl
php
php-ctype
php-curl
php-gd
php-iconv
php-json
php-libxml
php-mbstring
php-openssl
php-posix
php-session
php-xml
php-zip
php-zlib
php-pdo
php-mysqlnd
php-intl
php-bcmath
php-gmp
```

C) Récupérer NextCloud

```powershell
[user1@web www]$ sudo mkdir tp5_nextcloud
[user1@web www]$ ls
cgi-bin  html  tp5_nextcloud
```

```powershell
[user1@web tp5_nextcloud]$ curl -O https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0Warning: Failed to create the file nextcloud-25.0.0rc3.zip: Permission denied
  0  168M    0 16384    0     0   7892      0  6:12:24  0:00:02  6:12:22  7895
curl: (23) Failure writing output to destination
[user1@web tp5_nextcloud]$ sudo curl -O https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  168M  100  168M    0     0  6914k      0  0:00:24  0:00:24 --:--:-- 7781k
[user1@web tp5_nextcloud]$ ls
nextcloud-25.0.0rc3.zip
```

```powershell
[user1@web tp5_nextcloud]$ sudo dnf install unzip
Last metadata expiration check: 0:22:29 ago on Mon 09 Jan 2023 09:30:50 AM CET.
Dependencies resolved.
[...]
Complete!
```

```powershell
[user1@web tp5_nextcloud]$ sudo unzip nextcloud-25.0.0rc3.zip 
```

```powershell
[user1@web nextcloud]$ sudo cp -r * /var/www/tp5_nextcloud/
```

```powershell
[user1@web www]$ sudo chown apache -R tp5_nextcloud/
```

D) Adapter la configuration d'Apache

```powershell
[user1@web conf.d]$ cat tp5.conf 
<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp5_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp5.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp5_nextcloud/> 
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>

```

E) Redémarrer le service Apache

```powershell
[user1@web conf.d]$ sudo systemctl restart httpd
```

3. Finaliser l'installation de Nextcloud

```powershell
MacBook-Air-Yohan:etc yohan$ cat hosts | grep web
172.16.72.11 web.tp5.linux
```

A) Exploration de la base de données

```powershell
[user1@web conf.d]$ mysql -u nextcloud -h 172.16.72.12 -p
Enter password:
```

```powershell
mysql> select count(*) as nombre_de_tables
    -> from information_schema.tables
    -> where table_schema = 'nextcloud'
    -> ;
+------------------+
| nombre_de_tables |
+------------------+
|               95 |
+------------------+
1 row in set (0.01 sec)
```






