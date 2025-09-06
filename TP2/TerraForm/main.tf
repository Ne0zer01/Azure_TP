# main.tf

# Provider : AzureRM
# ===============================
# Ce bloc indique à Terraform qu’on travaille avec Azure
# et qu’on utilise notre abonnement (subscription_id).
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# ===============================
# Resource Group
# ===============================
# Le "dossier" logique qui contient toutes les ressources Azure.
# Tout sera créé à l'intérieur de ce Resource Group.
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# ===============================
# Virtual Network (VNet)
# ===============================
# C’est le réseau virtuel (comme un grand switch) où ta VM va être connectée.
# Il a une plage d’adresses IP définie ici : 10.0.0.0/16
resource "azurerm_virtual_network" "main" {
  name                = "vm-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# ===============================
# Subnet
# ===============================
# Le sous-réseau (comme un VLAN dans ton VNet).
# Ici, on crée un petit réseau : 10.0.1.0/24
resource "azurerm_subnet" "main" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ===============================
# Network Interface (NIC)
# ===============================
# C’est la carte réseau de ta VM.
# Elle est connectée au subnet et elle reçoit aussi une IP publique.
resource "azurerm_network_interface" "main" {
  name                = "vm-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# ===============================
# Public IP
# ===============================
# L’adresse IP publique qui sera assignée à ta VM pour pouvoir la joindre depuis Internet.
# allocation_method = "Static" → ton IP ne change pas
# sku = "Standard" → meilleure disponibilité
resource "azurerm_public_ip" "main" {
  name                = "vm-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# ===============================
# Virtual Machine (Linux)
# ===============================
# Création de la VM Linux (Ubuntu 20.04).
# On associe la carte réseau (NIC), un utilisateur SSH et un disque OS.
resource "azurerm_linux_virtual_machine" "main" {
  name                = "super-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  
  # Associe la VM à la carte réseau créée plus haut
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  # Clé SSH pour se connecter en toute sécurité (au lieu de mot de passe)
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.public_key_path)
  }

  # Disque système (OS disk)
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "vm-os-disk"
  }

  # Image Ubuntu 20.04 LTS
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}