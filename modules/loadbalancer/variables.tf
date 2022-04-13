
variable "zone" {
  type = string
}

variable "private_sdn_network" {
  type = string
}

variable "proxy_private_ip_addresses" {
  type = list(any)
}

variable "sql_client_ip_address" {
  type = string
}