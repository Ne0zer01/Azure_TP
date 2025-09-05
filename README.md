# 🌞 Déterminer quel algorithme de chiffrement utiliser pour vos clés :
Désromais l'utilisation de l'algorithme de chiffrement RSA est fortement déconseillée car considérer comme non sûres (notamment les clés de 1024 bits). Les clés de 3072 ou de 4092 sont acceptables mais posséde énormément de problémes : lenteur de la création des clés, les clés sont lourds a stocker,...  
Source fiable qui explique pourquoi on évite RSA : OpenSSH : https://www.openssh.com/txt/release-8.8 .  
Il est conseiller de remplacer RSA par l algorithme Ed25519 (plus rapide et plus sûrs). Elle offre un niveau de sécurité équivalent à une clé RSA de 3072 bits, mais avec une taille de clé plus petite et une résistance accrue aux erreurs de génération de nombres aléatoires.  
Source qui explique pourquoi on devrait utiliser Ed225519 : https://nikk.is-a.dev/blog/ed25119_n_rsa/  

# 🌞Générer une paire de clés pour ce TP :
La commande utilisée pour générer la paire de clés : ssh-keygen -t ed25519 -f C:/Users/DKhen/OneDrive/Desktop/TP_Azure/ssh -C "cloud_tp1"

# 🌞 Configurer un agent SSH sur votre poste (Les etapes):
```powershell
Remove-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
```
```powershell
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
```
```powershell
Get-Service -Name ssh-agent | Select-Object Name, Status, StartType
```
(a permis de voir le status et le StartType de l'agent SSH de Windows) ==> Status = stopped, StartType = Disabled
```powershell
Set-Service -Name ssh-agent -StartupType Automatic
```
(a parmis de changer le StartType de Disabled vers Automatic)
```powershell
Start-Service ssh-agent
```
(a permis de lancer l'agent SSH)
```powershell
ssh-add C:/Users/DKhen/OneDrive/Desktop/TP_Azure/ssh/cloud_tp1
```
(pour ajouter la clé dans l'agent SSH)
```powershell
ssh-add -l
```
(pour verifier que la clé a bien été ajouter)

# 🌞 Connectez-vous en SSH à la VM pour preuve
```powershell
PS C:\Users\DKhen> ssh  4.233.89.150
The authenticity of host '4.233.89.150 (4.233.89.150)' can't be established.
ED25519 key fingerprint is SHA256:9ObLEl6INH0fuiduO/lCiSLVk8Hoh0HSuJQFtsuzzHE.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '4.233.89.150' (ED25519) to the list of known hosts.
djamil@4.233.89.150: Permission denied (publickey).
```
```powershell
PS C:\Users\DKhen> ls .\.ssh\


    Directory: C:\Users\DKhen\.ssh


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        05/09/2025     12:23             95 known_hosts
```
```powershell
PS C:\Users\DKhen> ssh-add.exe "C:\Users\DKhen\OneDrive\Desktop\TP_Azure\ssh\cloud_tp1"
Enter passphrase for C:\Users\DKhen\OneDrive\Desktop\TP_Azure\ssh\cloud_tp1:
Identity added: C:\Users\DKhen\OneDrive\Desktop\TP_Azure\ssh\cloud_tp1 (cloud_tp1)
```
```powershell
PS C:\Users\DKhen> ssh  azureuser@4.233.89.150
Welcome to Ubuntu 24.04.3 LTS (GNU/Linux 6.11.0-1018-azure x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Fri Sep  5 10:26:16 UTC 2025

  System load:  0.11              Processes:             125
  Usage of /:   5.6% of 28.02GB   Users logged in:       0
  Memory usage: 3%                IPv4 address for eth0: 10.0.0.4
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update

Last login: Fri Sep  5 10:26:19 2025 from 209.206.8.251
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

azureuser@TP1:~$
logout
Connection to 4.233.89.150 closed.
```
# 🌞 Créez une VM depuis le Azure CLI
```powershell
az vm create `
  --resource-group Azure_TP `
  --name TP1.2 `
  --image Ubuntuw2404 `
  --admin-username djamil `
  --ssh-key-values C:\Users\Djamil\.ssh\id_rsa.pub `
  --location francecentral `
  --size Standard_D2s_v5
```
IP publique : 4.212.91.196
```powershell
PS C:\Users\DKhen> ssh djamil@4.212.91.196 Welcome to Ubuntu 24.04.3 LTS (GNU/Linux 6.11.0-1018-azure x86_64) * Documentation: https://help.ubuntu.com * Management: https://landscape.canonical.com * Support: https://ubuntu.com/pro System information as of Fri Sep 5 12:04:00 UTC 2025 System load: 0.05 Processes: 112 Usage of /: 5.7% of 28.02GB Users logged in: 0 Memory usage: 29% IPv4 address for eth0: 10.0.0.5 Swap usage: 0% Expanded Security Maintenance for Applications is not enabled. 0 updates can be applied immediately. Enable ESM Apps to receive additional future security updates. See https://ubuntu.com/esm or run: sudo pro status The list of available updates is more than a week old. To check for new updates run: sudo apt update Last login: Fri Sep 5 12:02:41 2025 from 209.206.8.251 To run a command as administrator (user "root"), use "sudo <command>". See "man sudo_root" for details. djamil@vmTP1:~$
```
