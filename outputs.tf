output "server_db_fqdn" {
  value = module.database.db_host
}

output "server_db_password" {
  value     = module.database.db_password
  sensitive = true
}
