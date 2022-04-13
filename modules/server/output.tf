output "sql_client_ip_address" {
  value = upcloud_server.sql-client.network_interface[0].ip_address
}