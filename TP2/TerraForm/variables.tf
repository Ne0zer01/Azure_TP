# variables.tf

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  default     = "francecentral"
  description = "Azure region"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
}

variable "public_key_path" {
  type        = string
  description = "Path to your SSH public key"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "storage_account_name" {
   type        = string
  description = "Nom unique du compte de stockage"
}

variable "storage_container_name" {
  type        = string
  description = "Nom du conteneur blob"
}

variable "alert_email_address" {
  description = "Adresse email qui recevra les alertes de monitoring"
  type        = string
}