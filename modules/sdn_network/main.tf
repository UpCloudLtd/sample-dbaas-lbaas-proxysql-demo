
resource "upcloud_network" "private_sdn_network" {
  name = "sqlproxy_sdn_network"
  zone = var.zone

  ip_network {
    address            = "10.10.10.0/24"
    dhcp               = true
    dhcp_default_route = false
    family             = "IPv4"
  }
}