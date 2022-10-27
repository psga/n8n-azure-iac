resource "azurerm_public_ip" "gw_ip" {
  name                = "pip-gateway"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
}
resource "tls_self_signed_cert" "example" {
  private_key_pem = tls_private_key.example.private_key_pem

  subject {
    common_name = "pusuga.me"
  }
  validity_period_hours = 8760
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}

resource "azurerm_application_gateway" "network" {
  name                = "appgw-n8n"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name = "Standard_v2" # Aqui pondriamos el WAF 'WAF_v2'
    tier = "Standard_v2" # Aqui pondriamos el WAF 'WAF_v2'

    capacity = 1
  }
  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = var.gateway_subnet_id
  }

  frontend_port {
    name = "port_80"
    port = 80
  }

  frontend_port {
    name = "port_443"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "my-frontendip"
    public_ip_address_id = azurerm_public_ip.gw_ip.id
  }
  backend_address_pool {
    name         = "n8n-backend-pool"
    ip_addresses = [var.vm_private_ip]
  }
  backend_http_settings {
    name                  = "http-settings-n8n"
    cookie_based_affinity = "Disabled"
    port                  = 5678
    protocol              = "http"
    request_timeout       = 60
  }
  http_listener {
    name                           = "listener- http"
    frontend_ip_configuration_name = "my-frontendip"
    frontend_port_name             = "port_80"
    protocol                       = "Http"
  }

  http_listener {
    name                           = "listener- https"
    frontend_ip_configuration_name = "my-frontendip"
    frontend_port_name             = "port_443"
    protocol                       = "Https"
    ssl_certificate_name           = "n8n-cart"
  }
  http_listener {
    name                           = "listener-http"
    frontend_ip_configuration_name = "my-frontendip"
    frontend_port_name             = "port_80"
    protocol                       = "Http"
  }
  redirect_configuration {
    name                 = "http-to-https"
    redirect_type        = "Permanent"
    target_listener_name = "listener-https"
    include_path         = true
    include_query_string = true
  }
  ssl_certificate {
    name     = "n8n-cert"
    data     = tls_self_signed_cert.example.cert_pem
    password = "" #in real certs here is the key 
  }
  request_routing_rule {
    name                        = "rule-http-redirect"
    rule_type                   = "basic"
    http_listener_name          = "listener-http"
    redirect_configuration_name = "http-to-https"
    priority                    = 20
  }
  request_routing_rule {
    name                       = "rule-https-to-n8n"
    rule_type                  = "basic"
    http_listener_name         = "listener-https"
    backend_address_pool_name  = "n8n-backend-pool"
    backend_http_settings_name = "http-settings-n8n"
    priority                   = 10
  }
}
