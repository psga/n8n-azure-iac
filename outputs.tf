output "server_db_fqdn" {
  value = module.database.db_host
}

output "server_db_password" {
  value     = module.database.db_password
  sensitive = true
}
# When VM has public ip
#output "n8n_ip" {
#  value = module.compute.n8n_ip
#}

output "name_servers" {
  value = module.dns.name_servers
}
