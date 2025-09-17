# TP3 : Cloud privé

## I. Présentation du lab :

### 🌞 Allumez les VMs et effectuez la conf élémentaire :

1. **_Adresse IP statique :_**  

```powershell
sudo nmcli con add type ethernet ifname enp0s8 con-name lan \
  ipv4.addresses 10.3.1.10/24 \
  ipv4.method manual \
  connection.autoconnect yes
sudo nmcli con up lan
```

```powershell
sudo nmcli con add type ethernet ifname enp0s8 con-name lan \
  ipv4.addresses 10.3.1.11/24 \
  ipv4.method manual \
  connection.autoconnect yes
sudo nmcli con up lan
```

```powershell
sudo nmcli con add type ethernet ifname enp0s8 con-name lan \
  ipv4.addresses 10.3.1.12/24 \
  ipv4.method manual \
  connection.autoconnect yes
sudo nmcli con up lan
```

2. **_Définition du nom de domaine avec hostnamectl :_**  

```powershell
sudo hostnamectl set-hostname frontend.one   # VM1
sudo hostnamectl set-hostname kvm1.one       # VM2
sudo hostnamectl set-hostname kvm2.one       # VM3
```

3. **_Remplissage des fichiers /etc/hosts des trois machines pour qu'elles se joignent avec leurs noms :_**

    **Installation de nano :**
    
    ```powershell
    sudo dnf install nano
    ```

    **(Les fichier /etc/hosts ont été remplis avec ces lignes) :**

    ```powershell
    10.3.1.10   frontend.one
    10.3.1.11   kvm1.one
    10.3.1.12   kvm2.one
    ```

4. **_Compte-rendu :_**

    **ping kvm1.one depuis frontend.one :**

    ```powershell
        [djamil@frontend ~]$ ping kvm1.one
        PING kvm1.one (10.3.1.11) 56(84) bytes of data.
        64 bytes from kvm1.one (10.3.1.11): icmp_seq=1 ttl=64 time=0.545 ms
        64 bytes from kvm1.one (10.3.1.11): icmp_seq=2 ttl=64 time=0.346 ms
        64 bytes from kvm1.one (10.3.1.11): icmp_seq=3 ttl=64 time=0.892 ms
        64 bytes from kvm1.one (10.3.1.11): icmp_seq=4 ttl=64 time=1.12 ms
        --- kvm1.one ping statistics ---
        4 packets transmitted, 4 received, 0% packet loss, time 3091ms
        rtt min/avg/max/mdev = 0.346/0.726/1.121/0.300 ms
    ```

    **ping kvm2.one depuis frontend.one :**

    ```powershell
    [djamil@frontend ~]$ ping kvm2.one
    PING kvm2.one (10.3.1.12) 56(84) bytes of data.
    64 bytes from kvm2.one (10.3.1.12): icmp_seq=1 ttl=64 time=0.410 ms
    64 bytes from kvm2.one (10.3.1.12): icmp_seq=2 ttl=64 time=1.00 ms
    64 bytes from kvm2.one (10.3.1.12): icmp_seq=3 ttl=64 time=1.02 ms
    64 bytes from kvm2.one (10.3.1.12): icmp_seq=4 ttl=64 time=1.08 ms
    ^C
    --- kvm2.one ping statistics ---
    4 packets transmitted, 4 received, 0% packet loss, time 3038ms
    rtt min/avg/max/mdev = 0.410/0.876/1.075/0.270 ms
    ```

## II.1. Setup Frontend :

## A. Database :

### 🌞 Installer un serveur MySQL :

**_Installation d'un serveur spécifique de MySQL, demander par OpenNebula :_**

```bash
wget https://dev.mysql.com/get/mysql80-community-release-el9-5.noarch.rpm
```

**_Ajout du dépot :_**

```bash
sudo rpm -ivh mysql80-community-release-el9-5.noarch.rpm
```

**_Vérification que le déport a bien été ajouter :_**

```bash
dnf repolist enabled | grep mysql
```

**_Installation du paquet contenant le serveur MySQL :_**

**Résultat de la commande 'dnf search mysql' :**

```bash
====================== Name & Summary Matched: mysql =======================
mysql.x86_64 : MySQL client programs and shared libraries
MySQL-zrm.noarch : MySQL backup manager
anope-mysql.x86_64 : MariaDB/MySQL modules for Anope IRC services
ansible-collection-community-mysql.noarch : MySQL collection for Ansible
apr-util-mysql.x86_64 : APR utility library MySQL DBD driver
asterisk-mysql.x86_64 : Applications for Asterisk that use MySQL
collectd-mysql.x86_64 : MySQL plugin for collectd
dovecot-mysql.x86_64 : MySQL back end for dovecot
exim-mysql.x86_64 : MySQL lookup support for Exim
gnokii-smsd-mysql.x86_64 : MySQL support for Gnokii SMS daemon
holland-mysql.noarch : MySQL library functionality for Holland Plugins
holland-mysqldump.noarch : Logical mysqldump backup plugin for Holland
holland-mysqllvm.noarch : Holland LVM snapshot backup plugin for MySQL
kdb-driver-mysql.x86_64 : Mysql driver for kdb
kf5-akonadi-server-mysql.x86_64 : Akonadi MySQL backend support
libdbi-dbd-mysql.x86_64 : MySQL plugin for libdbi
libnss-mysql.x86_64 : NSS library for MySQL
...
```
**Le paquet qu'on recherche :**

```bash
mysql-community-server.x86_64 : A very fast and reliable SQL database server
```
**Installation du serveur :**

```bash
sudo dnf install mysql-community-server
```

### 🌞 Démarrer le serveur MySQL :

**Démarrage du service mysqld :**

```bash
sudo systemctl start mysqld
```

**Vérification que le service a bien demarrer :**

```bash
sudo systemctl status mysqld
```

**Activation du service au démarrage :**

```bash
sudo systemctl enable mysqld
```

**Vérification que le service démarre bien au démarrage :**

```bash
sudo systemctl is-enabled mysqld
```

-> Résultat :

```bash
Enabled
```

### 🌞 Setup MySQL :

**Récupération du mot de passe temporaire :**

```bash
sudo grep 'temporary password' /var/log/mysqld.log
```

-> Exemple de résultat :

```bash
[Note] A temporary password is generated for root@localhost: XyZ123!@#
```

**Connexion à MySQL :**

```bash
sudo mysql -u root -p
```
**Les commandes MySQL effectuer :**

```mysql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'hey_boi_define_a_strong_password';
CREATE USER 'oneadmin' IDENTIFIED BY 'also_here_define_another_strong_password';
CREATE DATABASE opennebula;
GRANT ALL PRIVILEGES ON opennebula.* TO 'oneadmin';
SET GLOBAL TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

## B. OpenNebula :

### 🌞 Ajouter les dépôts Open Nebula :

```bash
sudo nano /etc/yum.repos.d/opennebula.repo
```

**Ajout de ceci dans le dépot opennebula.repo :**

```ini
[opennebula]
name=OpenNebula Community Edition
baseurl=https://downloads.opennebula.io/repo/6.10/RedHat/$releasever/$basearch
enabled=1
gpgkey=https://downloads.opennebula.io/repo/repo2.key
gpgcheck=1
repo_gpgcheck=1
```

**Vérification que le dépôt est bien activé :**

```bash
sudo dnf repolist | grep opennebula
```

Résultat ->

```bash
opennebula         OpenNebula Community Edition
```

**Téléchargement des métadonnées pour accélerer les installations :**

```bash
sudo dnf makecache -y
```

### 🌞 Installer OpenNebula :

```bash
sudo dnf install -y opennebula opennebula-sunstone opennebula-fireedge
```

**Vérification de l'installation :**

```bash
rpm -qa | grep opennebula
```

Résultat -> 

```bash
opennebula-common-onecfg-6.10.0.1-1.el9.noarch
opennebula-common-6.10.0.1-1.el9.noarch
opennebula-rubygems-6.10.0.1-1.el9.x86_64
opennebula-libs-6.10.0.1-1.el9.noarch
opennebula-provision-data-6.10.0.1-1.el9.noarch
opennebula-guacd-6.10.0.1-1.2.0+1.el9.x86_64
opennebula-tools-6.10.0.1-1.el9.noarch
opennebula-6.10.0.1-1.el9.x86_64
opennebula-sunstone-6.10.0.1-1.el9.noarch
opennebula-fireedge-6.10.0.1-1.el9.x86_64
```

### 🌞 Configuration OpenNebula :

```bash
sudo nano /etc/one/oned.conf
```

**Remplacement des paramètres de DB par :**

```
DB = [ BACKEND = "mysql",
       SERVER  = "localhost",
       PORT    = 0,
       USER    = "oneadmin",
       PASSWD  = "also_here_define_another_strong_password",
       DB_NAME = "opennebula",
       CONNECTIONS = 25,
       COMPARE_BINARY = "no" ]
```

### 🌞 Créer un user pour se log sur la WebUI OpenNebula :

**se log en tant q'utilisateur oneadmin :**

```bash
sudo su - oneadmin
```

**Changement du mot de passe de one_auth :**

```bash
nano /var/lib/one/.one/one_auth
```

### 🌞 Démarrer les services OpenNebula :

**Démarrage des services** *_opennebula_*, *_opennebula-sunstone_* :

```bash
sudo systemctl start opennebula
sudo systemctl start opennebula-sunstone
```

**Activer les services au démarrage :**

```bash
sudo systemctl enable opennebula
sudo systemctl enable opennebula-sunstone
```

## C. Conf système

### 🌞 Ouverture firewall :

**Ajouter les ports de façon permanente :**

```bash
  sudo firewall-cmd --permanent --add-port=9869/tcp   # WebUI Sunstone
  sudo firewall-cmd --permanent --add-port=22/tcp     # SSH
  sudo firewall-cmd --permanent --add-port=2633/tcp   # oned / XML-RPC
  sudo firewall-cmd --permanent --add-port=4124/tcp   # Monitoring TCP
  sudo firewall-cmd --permanent --add-port=4124/udp   # Monitoring UDP
  sudo firewall-cmd --permanent --add-port=29876/tcp  # NoVNC proxy
```

**Recharger firewalld pour appliquer les changements :**

```bash
  sudo firewall-cmd --reload
```

**Vérifier que les ports sont ouverts :**

```bash
  sudo firewall-cmd --list-ports
```

## II.2. Noeuds KVM :

### 🌞 Ajout des dépôts supplémentaires :

**Ajout es dépôts de OpenNebula :**

```bash
  sudo nano /etc/yum.repos.d/opennebula.repo
```

**Ajout des dépôts du serveur MySQL communautaire :**

```bash
  wget https://dev.mysql.com/get/mysql80-community-release-el9-5.noarch.rpm
  sudo rpm -ivh mysql80-community-release-el9-5.noarch.rpm
 ```

 **Ajout des dépôts EPEL :**

 ```bash
  sudo dnf install -y epel-release
 ```

 ### 🌞 Installer les libs MySQL :

 ```bash
  dnf install -y mysql-community-server
 ```

 ### 🌞 Installer KVM :

 ```bash
  sudo dnf install -y opennebula-node-kvm
 ```

 ### 🌞 Dépendances additionnelles :

 ```bash
  sudo dnf install -y genisoimage
 ```

 ### 🌞 Démarrer le service *_libvirtd_* :

 ```bash
  sudo systemctl start libvirtd
  sudo systemctl enable libvirtd
 ```

 ### 🌞 Ouverture firewall :

 ```bash
  sudo firewall-cmd --permanent --add-port=22/tcp
  sudo firewall-cmd --permanent --add-port=8472/udp
```

### 🌞 Handle SSH :

```bash
  [djamil@frontend ~]$ sudo -su oneadmin
  [sudo] password for djamil:
  [oneadmin@frontend djamil]$ ssh djamil@10.3.1.11
  Warning: Permanently added '10.3.1.11' (ED25519) to the list of known hosts.
  djamil@10.3.1.11''s password:
  Last login: Tue Sep 16 12:16:54 2025 from 10.3.1.13
  [djamil@kvm1 ~]$
```

**une paire de clés SSH a été générée sur l'utilisateur *_oneadmin_* :**

```bash
 ls -ls .ssh
```

Résultat ->

```bash
  total 28
  4 -rwxr-x---. 1 oneadmin oneadmin  575 Sep 16 09:27 authorized_keys
  4 -rwxr-x---. 1 oneadmin oneadmin 1444 Sep 16 09:25 config
  4 -r--------. 1 oneadmin oneadmin 2610 Sep 16 09:27 id_rsa
  4 -rwxr-x---. 1 oneadmin oneadmin  575 Sep 16 09:27 id_rsa.pub
  8 -rw-------. 1 oneadmin oneadmin 4125 Sep 16 16:20 known_hosts
  4 -rw-r--r--. 1 oneadmin oneadmin   91 Sep 16 14:24 known_hosts.old
```

**Dépot de la clé publique sur les noeuds KVM (dans le dossier .ssh/):**

```bash
  scp .ssh/id_rsa oneadmin@10.3.1.11:/tmp
  scp .ssh/id_rsa.pub oneadmin@10.3.1.11:/tmp
  mv /tmp/id_rsa* .ssh/
```


**trust les empreintes des autres serveurs :**

```bash
  ssh-keyscan 10.3.1.11 10.3.1.10 >> .ssh/known_hosts
```