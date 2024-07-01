resource "upcloud_managed_database_mysql" "dbaas_mysql" {
  name  = "demo-mysql-dbaas"
  title = "demo-mysql-dbaas"
  plan  = var.dbaas_plan
  zone  = var.zone
  network {
    family = "IPv4"
    name   = "mysql-backend-network"
    type   = "private"
    uuid   = var.private_sdn_network_be
  }
}
resource "upcloud_managed_database_logical_database" "testdb" {
  service = upcloud_managed_database_mysql.dbaas_mysql.id
  name    = "testdb"
}

resource "upcloud_managed_database_user" "testuser" {
  service  = upcloud_managed_database_mysql.dbaas_mysql.id
  username = "testuser"
}
resource "upcloud_managed_database_user" "monitor" {
  service  = upcloud_managed_database_mysql.dbaas_mysql.id
  username = "monitor"
}