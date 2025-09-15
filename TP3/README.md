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