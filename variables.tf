variable "resource_group_name" {
  default = "rg-n8n-produccion"
}

variable "location" {
  default = "eastus2" # Pendiente probar 
}

variable "vnet_cidr" {
  default = ["10.0.0.0/16"]
}
