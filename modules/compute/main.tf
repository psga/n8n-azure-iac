# The ip public for for enter to n8n
#resource "azurerm_public_ip" "n8n_ip" {
#  name                = "pip-n8n"
#  resource_group_name = var.resource_group_name
#  location            = var.location
#  allocation_method   = "Static"
#  sku                 = "Standard"
#}
#to remove
resource "azurerm_network_interface" "n8n_nic" {
  name                = "nic-n8n"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.public_subnet_id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id          = azurerm_public_ip.n8n_ip.id
    # to remove
  }
}
# VM 
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}
resource "azurerm_linux_virtual_machine" "n8n_vm" {
  name                  = "vm-n8n-server-${random_string.suffix.result}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = "Standard_B1ms" #2 gb ram
  network_interface_ids = [azurerm_network_interface.n8n_nic.id]
  admin_username        = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("./id_rsa_n8n.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  custom_data = base64encode(<<-EOF
  #!/bin/bash
  sudo apt-get update -y
  sudo apt-get install -y docker.io
  sudo systemctl start docker
  sudo systemctl enable docker

  docker run -d --name n8n \
  -p 5678:5678 \
  -e DB_TYPE=postgresdb \
  -e DB_POSTGRESDB_HOST=${var.db_host} \
  -e DB_POSTGRESDB_PORT=5432 \
  -e DB_POSTGRESDB_DATABASE=n8n_db \
  -e DB_POSTGRESDB_USER=n8nadmin \
  -e DB_POSTGRESDB_PASSWORD='${var.db_password}' \
  -e N8N_ENCRYPTION_KEY=una-clave-secreta-123 \
  -e DB_POSTGRESDB_SSL_MODE=require \
  -e DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=false \
  -e N8N_SECURE_COOKIE=false \
  --restart always \
  docker.n8n.io/n8nio/n8n
  EOF
  )
}
