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
