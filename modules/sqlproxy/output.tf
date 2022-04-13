output "proxy_ip_addresses" {
  value = [
    upcloud_server.sql-proxy-server[0].network_interface[0].ip_address,
    upcloud_server.sql-proxy-server[1].network_interface[0].ip_address
  ]
}

output "proxy_private_ip_addresses" {
  value = [
    upcloud_server.sql-proxy-server[0].network_interface[2].ip_address,
    upcloud_server.sql-proxy-server[1].network_interface[2].ip_address
  ]
}