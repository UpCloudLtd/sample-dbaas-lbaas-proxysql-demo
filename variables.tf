variable "private_sdn_network" {
  type    = string
  default = ""
}

variable "zone" {
  type = string
}

variable "dbaas_plan" {
  type = string
}

variable "sqlproxy_plan" {
  type = string
}

variable "ssh_key_public" {
  type = string
}

variable "sqlproxy_sdn_ip" {
  type    = string
  default = ""
}

variable "proxy_private_ip_addresses" {
  type    = list(any)
  default = [""]
}

variable "dbaas_mysql_hosts" {
  type    = list(any)
  default = [""]
}

variable "dbaas_mysql_port" {
  type    = string
  default = ""
}

variable "dbaas_mysql_database" {
  type    = string
  default = ""
}

variable "dbaas_mysql_username" {
  type    = string
  default = ""
}

variable "dbaas_mysql_password" {
  type    = string
  default = ""
}

variable "dbaas_mysql_monitor_username" {
  type    = string
  default = ""
}

variable "dbaas_mysql_monitor_password" {
  type    = string
  default = ""
}

variable "dbaas_mysql_default_username" {
  type    = string
  default = ""
}

variable "dbaas_mysql_default_password" {
  type    = string
  default = ""
}