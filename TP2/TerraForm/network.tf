# ===============================
# Récupération de l'IP publique de ton poste
# ===============================
# Ce bloc "data" demande à un service web (ifconfig.me)
# de donner ton IP publique actuelle.
# Cette IP sera utilisée dans la règle de sécurité (NSG)
# pour n'autoriser QUE toi à te connecter en SSH.
#data "http" "my_ip" {
#  url = "https://ifconfig.me"
#}

# ===============================
# Network Security Group (NSG)
# ===============================
# C’est le "pare-feu" d’Azure : il décide quel trafic
# peut entrer ou sortir de ta machine.
# Ici, on crée un NSG appelé "vm-nsg".
resource "azurerm_network_security_group" "main" {
  name                = "vm-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Règle de sécurité : autoriser SSH uniquement depuis ton IP
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100             # ordre d'application (100 = haute priorité)
    direction                  = "Inbound"       # trafic entrant
    access                     = "Allow"         # autoriser
    protocol                   = "Tcp"           # protocole TCP (SSH utilise TCP)
    source_port_range          = "*"             # n'importe quel port source
    destination_port_range     = "22"            # autorise seulement le port SSH (22)
    source_address_prefixes    = [chomp(data.http.my_ip.response_body)] # ton IP publique
    destination_address_prefix = "*"             # la VM (peu importe son IP interne)
  }
}

# ===============================
# Association NSG ↔ NIC
# ===============================
# Ce bloc attache le NSG "vm-nsg" à ta carte réseau (NIC).
# Sans cette étape, le NSG existe mais ne protège rien !
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}
