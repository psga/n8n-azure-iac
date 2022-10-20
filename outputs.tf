output "server_db_fqdn" {
  value = module.database.db_host
}

output "server_db_password" {
  value     = module.database.db_password
  sensitive = true
}

output "n8n_ip" {
  value = module.compute.n8n_ip
}
