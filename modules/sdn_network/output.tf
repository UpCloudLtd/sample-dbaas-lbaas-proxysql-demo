output "private_sdn_network_proxysql" {
  value = upcloud_network.private_sdn_network_proxysql.id
}

output "private_sdn_network_client" {
  value = upcloud_network.private_sdn_network_client.id
}

output "private_sdn_network_client_address" {
  value = upcloud_network.private_sdn_network_client.ip_network[0].address
}

output "private_sdn_network_be" {
  value = upcloud_network.private_mysql_be.id
}