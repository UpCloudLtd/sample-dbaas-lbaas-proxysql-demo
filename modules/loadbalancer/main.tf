
resource "upcloud_loadbalancer" "lb" {
  configured_status = "started"
  name              = "SQL-LB"
  plan              = "production-small"
  zone              = var.zone
  networks {
    name = "SDN-Network"
    family = "IPv4"
    type = "private"
    network = var.private_sdn_network
  }
  networks {
    name   = "Public-Network"
    type   = "public"
    family = "IPv4"
  }
  depends_on        = [var.proxy_private_ip_addresses]
}


resource "upcloud_loadbalancer_backend" "lb_be" {
  loadbalancer = upcloud_loadbalancer.lb.id
  name         = "proxy-servers"
}

resource "upcloud_loadbalancer_static_backend_member" "lb_be_member1" {
  backend      = upcloud_loadbalancer_backend.lb_be.id
  name         = "proxy0"
  ip           = var.proxy_private_ip_addresses[0]
  port         = 6033
  weight       = 100
  max_sessions = 1000
  enabled      = true
}

resource "upcloud_loadbalancer_static_backend_member" "lb_be_member2" {
  backend      = upcloud_loadbalancer_backend.lb_be.id
  name         = "proxy1"
  ip           = var.proxy_private_ip_addresses[1]
  port         = 6033
  weight       = 100
  max_sessions = 1000
  enabled      = true
}

resource "upcloud_loadbalancer_frontend" "lb_fe" {
  loadbalancer         = upcloud_loadbalancer.lb.id
  name                 = "SQL-lB"
  mode                 = "tcp"
  port                 = 3306
  networks {
    name = upcloud_loadbalancer.lb.networks[1].name
  }
  default_backend_name = upcloud_loadbalancer_backend.lb_be.name
}

resource "upcloud_loadbalancer_frontend_rule" "lb_fe_rule1" {
  frontend = upcloud_loadbalancer_frontend.lb_fe.id
  name     = "accept-clients"
  priority = 100

  matchers {
    src_ip {
      value = var.sql_client_ip_address
    }
  }
  actions {
    use_backend {
      backend_name = upcloud_loadbalancer_backend.lb_be.name
    }
  }
}

resource "upcloud_loadbalancer_frontend_rule" "lb_fe_rule2" {
  frontend = upcloud_loadbalancer_frontend.lb_fe.id
  name     = "deny-any"
  priority = 1

  matchers {
    src_ip {
      value = "0.0.0.0/0"
    }
  }
  actions {
    tcp_reject {}
  }
}