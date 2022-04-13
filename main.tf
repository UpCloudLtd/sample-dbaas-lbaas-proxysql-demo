
module "dbaas_mysql" {
  source     = "./modules/dbaas_mysql"
  dbaas_plan = var.dbaas_plan
  zone       = var.zone
}
module "sdn_network" {
  source = "./modules/sdn_network"
  zone   = var.zone
}

module "sqlproxy" {
  source                       = "./modules/sqlproxy"
  ssh_key_public               = var.ssh_key_public
  zone                         = var.zone
  sqlproxy_plan                = var.sqlproxy_plan
  private_sdn_network          = module.sdn_network.private_sdn_network
  dbaas_mysql_hosts            = module.dbaas_mysql.dbaas_mysql_hosts
  dbaas_mysql_port             = module.dbaas_mysql.dbaas_mysql_port
  dbaas_mysql_username         = module.dbaas_mysql.dbaas_mysql_username
  dbaas_mysql_password         = module.dbaas_mysql.dbaas_mysql_password
  dbaas_mysql_monitor_username = module.dbaas_mysql.dbaas_mysql_monitor_username
  dbaas_mysql_monitor_password = module.dbaas_mysql.dbaas_mysql_monitor_password
  dbaas_mysql_default_username = module.dbaas_mysql.dbaas_mysql_default_username
  dbaas_mysql_default_password = module.dbaas_mysql.dbaas_mysql_default_password
}

module "server" {
  source               = "./modules/server"
  ssh_key_public       = var.ssh_key_public
  zone                 = var.zone
  private_sdn_network  = module.sdn_network.private_sdn_network
  dbaas_mysql_database = module.dbaas_mysql.dbaas_mysql_database
  dbaas_mysql_username = module.dbaas_mysql.dbaas_mysql_username
  dbaas_mysql_password = module.dbaas_mysql.dbaas_mysql_password
}

module "loadbalancer" {
  source                     = "./modules/loadbalancer"
  zone                       = var.zone
  proxy_private_ip_addresses = module.sqlproxy.proxy_private_ip_addresses
  private_sdn_network        = module.sdn_network.private_sdn_network
  sql_client_ip_address      = module.server.sql_client_ip_address
}