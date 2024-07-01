variable "ssh_key_public" {
  type = string
}

variable "zone" {
  type = string
}

variable "sqlproxy_plan" {
  type = string
}

variable "private_sdn_network_proxysql" {
  type = string
}
variable "private_sdn_network_be" {
  type = string
}
variable "dbaas_mysql_hosts" {
  type = list(any)
}

variable "dbaas_mysql_port" {
  type = string
}

variable "dbaas_mysql_username" {
  type = string
}

variable "dbaas_mysql_password" {
  type = string
}
variable "dbaas_mysql_monitor_username" {
  type = string
}

variable "dbaas_mysql_monitor_password" {
  type = string
}

variable "dbaas_mysql_default_username" {
  type = string
}

variable "dbaas_mysql_default_password" {
  type = string
}