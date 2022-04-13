variable "ssh_key_public" {
  type = string
}

variable "zone" {
  type = string
}

variable "sqlproxy_sdn_ip" {
  type    = string
  default = ""
}

variable "private_sdn_network" {
  type = string
}

variable "dbaas_mysql_username" {
  type = string
}

variable "dbaas_mysql_password" {
  type = string
}
variable "dbaas_mysql_database" {
  type = string
}