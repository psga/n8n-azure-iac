# 1. Create the Group Resources 
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# 2. The Virtual Network (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-n8n-network"
  address_space       = var.vnet_cidr
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# 3. The public subnet (when the n8n server and the balancer) 
resource "azurerm_subnet" "public_subnet" {
  name                 = "snet-public"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 4. The private subnet (for the  PostgreSQL bd)
resource "azurerm_subnet" "private_subnet" {
  name                 = "snet-private"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# 5. Network Security Group (NSG)  
resource "azurerm_network_security_group" "nsg_public" {
  name                = "nsg-public-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*" # when i start to create my vm 
    destination_address_prefix = "*"
  }
}

# 6. Asociate the NSG to the public net 
resource "azurerm_subnet_network_security_group_association" "public_assoc" {
  subnet_id                 = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_public.id
}
