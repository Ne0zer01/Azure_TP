output "public_ip_address" {
  description = "Adresse IP publique de la VM"
  value       = azurerm_public_ip.main.ip_address
}

output "public_ip_dns" {
  description = "Nom DNS public de la VM"
  value       = azurerm_public_ip.main.fqdn
}

output "ssh_command" {
  description = "Commande SSH vers la VM"
  value       = "ssh djamil@${azurerm_public_ip.main.fqdn}"

  #Avec ce output je n'aurais pas besoin de taper la commande a chaque fois ni de la chercher quelque part pour mon rappeler (juste un ctrl+C ctrl+V)
}
