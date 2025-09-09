# I. Network Security Group

## 🌞 Ajouter un NSG à votre déploiement Terraform
Le fichier **_network.tf_** a été ajouter.

## 🌞 Prouver que ça fonctionne, rendu attendu :
1) la sortie du **_terraform apply_** :
    ```powershell
    Apply complete! Resources: 8 added, 0 changed, 0 destroyed.
    ```
2) une commande **_az_** pour obtenir toutes les infos liées à la VM :

    ```powershell
    az vm show `
    --name super-vm `
    --resource-group Axure_Test `
    --query "networkProfile.networkInterfaces[].id"
    ```  

    **_Resultat (Id du NSG)_**

    ```powershell
    "/subscriptions/344fb974-6d09-41dc-b4d0-77bf422b1b8e/resourceGroups/Azure_Test/providers/Microsoft.Network/networkInterfaces/vm-nic"
    ```
    ```powershell
        az network nic show `
    --ids "/subscriptions/344fb974-6d09-41dc-b4d0-77bf422b1b8e/resourceGroups/Azure_Test/providers/Microsoft.Network/networkInterfaces/vm-nic" `
    --query "networkSecurityGroup"
    ```

    **_Resultat (ID du NSG relier a ma VM)_**

    ```powershell
    {
    "id": "/subscriptions/344fb974-6d09-41dc-b4d0-77bf422b1b8e/resourceGroups/Azure_Test/providers/Microsoft.Network/networkSecurityGroups/vm-nsg",
    "resourceGroup": "Azure_Test"
    }
    ```

<!-- **_Explication du code_** -->

<!-- **--resource-group Azure_Test** → nom du Resource Group  
**--name super-vm** → nom de ta VM  
**--show-details** → inclut IP publique, disques, OS, etc.  
**--query** → filtre les infos pour afficher uniquement :  
*Nom de la VM (VMName)*  
*Localisation (Location)*  
*Taille de la VM (Size)*  
*Type de disque OS (OS)*  
*IP publique (PublicIP)*  
*NIC(s) (NICs)*  
*NSG attaché à la première NIC (NSG)*  
**-o json** → format JSON lisible -->

3) une commande **_ssh_** fonctionnelle vers l'IP publique de la VM :
    ```powershell
    ssh djamil@4.211.202.226
    ```
    L'utilisation du mot de passe na pas été utiliser grace a l'Agent SSH

4) changement de port :

     1. modifiez le port d'écoute du serveur OpenSSH sur la VM pour le port 2222/tcp :

         ```bash
        sudo nano /etc/ssh/sshd_config
        ```
        (Permet d'éditer le fichier de configuration SSH pour ajouter le port 2222)

        ```bash
        Redémarrer le service SSH
        ```
        (Pour redémarrer le service SSH)
    2. prouvez que le serveur OpenSSH écoute sur ce nouveau port (avec une commande ss sur la VM) :

        ```bash
        sudo ss -tlnp | grep sshd
        ```
        Résultat :
        ```bash
        LISTEN    0         128                0.0.0.0:2222             0.0.0.0:*        users:(("sshd",pid=2056,fd=3))         
        LISTEN    0         128                0.0.0.0:22               0.0.0.0:*        users:(("sshd",pid=2056,fd=5))         
        LISTEN    0         128                   [::]:2222                [::]:*        users:(("sshd",pid=2056,fd=4))         
        LISTEN    0         128                   [::]:22                  [::]:*        users:(("sshd",pid=2056,fd=6))
        ```
    3. prouvez qu'une nouvelle connexion sur ce port 2222/tcp ne fonctionne pas à cause du NSG :
        ```powershell
        ssh -p 2222 djamil@4.211.202.204
        ```
        Résultat :
        ```powershell
        ssh: connect to host <IP_publique> port 2222: Connection timed out
        ```
        (Le timeout indique que le paquet n’atteint pas la VM. Si le problème venait de SSH côté VM, tu aurais plutôt **Connection refused**.)  

# II. Un ptit nom DNS

## 🌞 Donner un nom DNS à votre VM

```terraform
domain_name_label   = "monvmtest"
```

## 🌞 Un ptit output nan ?

Le fichier outputs.tf a été crée.

## 🌞 Proofs ! Donnez moi :

**la sortie du terraform apply (ce qu'affiche votre outputs.tf) :**

```powershell
Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

Outputs:

public_ip_address = "20.188.40.55"
public_ip_dns = "monvmtest.francecentral.cloudapp.azure.com"
```

**une commande ssh fonctionnelle vers le nom de domaine (pas l'IP) :**

```powershell
ssh djamil@monvmtest.francecentral.cloudapp.azure.com
```

# III. Blob storage

## 🌞 Prouvez que tout est bien configuré, depuis la VM Azure

1) Installation de **_azcopy_** dans la VM :

    ```bash
    # Télécharger le tar.gz d'AzCopy
    wget https://aka.ms/downloadazcopy-v10-linux -O azcopy.tar.gz

    # Décompresser
    tar -xvzf azcopy.tar.gz

    # Copier le binaire dans /usr/local/bin
    sudo cp azcopy_linux_amd64_*/azcopy /usr/local/bin/

    # Vérifier l'installation
    azcopy --version
    ```

2) Authentification automatiquement :

    ```bash
    djamil@super-vm:~$ azcopy login --identity
    INFO: Login with identity succeeded.
    ```

3) Écriture d'un fichier dans le Storage Container créé (grace a **_azcopy_**):
    ```bash
    djamil@super-vm:~$ echo "Bonjour depuis ma VM Azure" > test.txt
    djamil@super-vm:~$ azcopy copy test.txt "https://storagetestdjamil01.blob.core.windows.net/blobtestdjamil01/test.txt" --from-to=LocalBlob
    ```

4) Lecture du fichier (grace a **_azcopy_**) :

    ```bash
    djamil@super-vm:~$ azcopy copy "https://storagetestdjamil01.blob.core.windows.net/meowcontainer/test.txt" ./test_downloaded.txt --from-to=BlobLocal
    djamil@super-vm:~$ cat test_downloaded.txt
    ```

## 🌞 Déterminez comment azcopy login --identity vous a authentifié

**_Comment azcopy login --identity fonctionne_** :

1. **_Managed Identity de la VM_** :

    La VM Azure a une Managed Identity (SystemAssigned) que tu as activée dans Terraform.

    Cette identité est gérée par Azure, pas besoin de clé ni de mot de passe.

2. **_Authentification auprès d’Azure AD_** :

    Quand tu fais azcopy login --identity, AzCopy demande un token d’accès (JWT) à Azure AD pour cette identité.

    Azure AD vérifie que la VM est bien autorisée et renvoie un token JWT valide pour accéder aux ressources Azure.

3. **_Utilisation du token pour Storage_** :

    AzCopy utilise ce token JWT pour authentifier toutes les opérations sur le Storage Account (upload/download).

    Le token a une durée limitée (généralement 1 heure) et est renouvelé automatiquement si nécessaire.

## 🌞 Requêtez un JWT d'authentification auprès du service que vous venez d'identifier, manuellement :

```bash
curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2019-08-01&resource=https://storage.azure.com/' -H "Metadata:true"
```

## 🌞 Expliquez comment l'IP 169.254.169.254 peut être joignable :

**_L’IP 169.254.169.254 : Instance Metadata Service (IMDS)_** :

Cette IP spéciale n’est pas sur Internet, elle est link-local (adresse réseau local : 169.254.0.0/16).  
Tous les systèmes Linux/Windows savent que les IPs 169.254.x.x sont accessibles directement sur le réseau local de la VM, sans passer par une gateway externe.

**_Pourquoi elle est joignable depuis la VM_** :

1. Chaque VM a une table de routage locale.
2. La table contient une route pour le **_sous-réseau link-local (169.254.0.0/16)_** :

    ```bash
    Destination     Gateway       Interface
    169.254.0.0/16  0.0.0.0      eth0
    ```

Donc toute requête vers 169.254.169.254 **_reste locale à la VM_**, elle ne sort pas vers le réseau public.  
Azure installe un petit service sur l’hôte de la VM qui **_redirige automatiquement_** ces requêtes vers le IMDS pour fournir les métadonnées de la VM (ex : Managed Identity, hostname, etc.).