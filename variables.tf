variable "resource_group_name" {
  default = "rg-n8n-produccion"
}

variable "location" {
  default = "centralus"
}

variable "vnet_cidr" {
  default = ["10.0.0.0/16"]
}
