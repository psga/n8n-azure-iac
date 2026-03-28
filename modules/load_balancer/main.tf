#  The public IP for the gateway
# Must be SKU "Standart" and the asignation Static to work with app gateway
resource "azurerm_public_ip" "gw_ip" {
  name                = "pip-gateway"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}
# The application gateway  (the network brain)
resource "azurerm_application_gateway" "network" {
  name                = "appgw-n8n"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_v2" # In this option we can use the firewall WAF  
    tier     = "Standard_v2"
    capacity = 1 # The minimun capacity to save costs 
  }
  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101" # Esta versión soporta TLS 1.2 y es moderna
  }

  # configuration of the gateway ip 
  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = var.gateway_subnet_id
  }

  # Puertos de entrada (Solo el 80 por ahora para evitar errores de certificado)
  frontend_port {
    name = "port_80"
    port = 80
  }

  # IP Pública que el usuario verá en internet
  frontend_ip_configuration {
    name                 = "my-frontend-ip"
    public_ip_address_id = azurerm_public_ip.gw_ip.id
  }

  # Backend Pool: A donde el Gateway envía el tráfico (Nuestra VM de n8n)
  backend_address_pool {
    name         = "n8n-backend-pool"
    ip_addresses = [var.vm_private_ip] # Recibe la IP privada de la VM desde la raíz
  }

  # Configuración HTTP del Backend: Cómo habla el Gateway con n8n
  backend_http_settings {
    name                  = "http-settings-n8n"
    cookie_based_affinity = "Disabled"
    port                  = 5678 # n8n escucha por defecto en el 5678
    protocol              = "Http"
    request_timeout       = 60
  }

  # El Listener: El "oído" que escucha las peticiones en el puerto 80
  http_listener {
    name                           = "listener-http"
    frontend_ip_configuration_name = "my-frontend-ip"
    frontend_port_name             = "port_80"
    protocol                       = "Http"
  }

  # La Regla de Enrutamiento: Une el Listener con el Backend
  request_routing_rule {
    name                       = "rule-http-to-n8n"
    rule_type                  = "Basic"
    http_listener_name         = "listener-http"
    backend_address_pool_name  = "n8n-backend-pool"
    backend_http_settings_name = "http-settings-n8n"
    priority                   = 10 # Prioridad requerida en v2
  }
}
