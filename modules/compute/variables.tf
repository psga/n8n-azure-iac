variable "location" {}
variable "resource_group_name" {}
variable "public_subnet_id" {}
variable "admin_username" {
  type    = string
  default = "admin_pablo"
}
variable "db_host" {}
variable "db_password" {}
variable "key_vault_name" {}

