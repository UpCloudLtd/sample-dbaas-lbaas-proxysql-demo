output "dbaas_mysql_hosts" {
  value = [upcloud_managed_database_mysql.dbaas_mysql.components[0].host, upcloud_managed_database_mysql.dbaas_mysql.components[1].host]
}
output "dbaas_mysql_port" {
  value = upcloud_managed_database_mysql.dbaas_mysql.service_port
}
output "dbaas_mysql_password" {
  value = upcloud_managed_database_user.testuser.password
}
output "dbaas_mysql_username" {
  value = upcloud_managed_database_user.testuser.username
}
output "dbaas_mysql_monitor_password" {
  value = upcloud_managed_database_user.monitor.password
}
output "dbaas_mysql_monitor_username" {
  value = upcloud_managed_database_user.monitor.username
}
output "dbaas_mysql_default_password" {
  value = upcloud_managed_database_mysql.dbaas_mysql.service_password
}
output "dbaas_mysql_default_username" {
  value = upcloud_managed_database_mysql.dbaas_mysql.service_username
}
output "dbaas_mysql_database" {
  value = upcloud_managed_database_logical_database.testdb.name
}