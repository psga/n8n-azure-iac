# this block is to get the current data of azure 
data "azurerm_client_config" "current" {}

# 1. Resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# 2. We call the Network module
module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_cidr           = ["10.0.0.0/16"]
  my_ip               = "186.121.0.234/32"
}

# 3. We call the Database module
module "database" {
  source              = "./modules/database"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_id             = module.network.vnet_id
  vnet_name           = module.network.vnet_name         # <--- Connection between modules
  private_subnet_id   = module.network.private_subnet_id # <--- Connection between modules
}

# 4. We call the Compute module
module "compute" {
  source              = "./modules/compute"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  public_subnet_id    = module.network.public_subnet_id
  db_host             = module.database.db_host
  db_password         = module.database.db_password
  key_vault_name      = module.security.key_vault_name
}

module "dns" {
  source              = "./modules/DNS"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  gateway_ip          = module.load_balancer.gateway_ip
}

module "load_balancer" {
  source              = "./modules/load_balancer"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  gateway_subnet_id   = module.network.gateway_subnet_id
  vm_private_ip       = module.compute.vm_private_ip
}
module "security" {
  source              = "./modules/security"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  db_password         = module.database.db_password
}

resource "azurerm_role_assignment" "assign_kv_access" {
  scope                = module.security.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.compute.vm_principal_id
}

resource "azurerm_role_assignment" "pablo_kv_admin" {
  scope                = module.security.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}
