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
