
resource "upcloud_loadbalancer" "lb" {
  configured_status = "started"
  name              = "SQL-LB"
  plan              = "production-small"
  zone              = var.zone
  network           = var.private_sdn_network
  depends_on        = [var.proxy_private_ip_addresses]
}


resource "upcloud_loadbalancer_backend" "lb_be" {
  loadbalancer = resource.upcloud_loadbalancer.lb.id
  name         = "proxy-servers"
}

resource "upcloud_loadbalancer_static_backend_member" "lb_be_member1" {
  backend      = resource.upcloud_loadbalancer_backend.lb_be.id
  name         = "proxy0"
  ip           = var.proxy_private_ip_addresses[0]
  port         = 6033
  weight       = 100
  max_sessions = 1000
  enabled      = true
}

resource "upcloud_loadbalancer_static_backend_member" "lb_be_member2" {
  backend      = resource.upcloud_loadbalancer_backend.lb_be.id
  name         = "proxy1"
  ip           = var.proxy_private_ip_addresses[1]
  port         = 6033
  weight       = 100
  max_sessions = 1000
  enabled      = true
}

resource "upcloud_loadbalancer_frontend" "lb_fe" {
  loadbalancer         = resource.upcloud_loadbalancer.lb.id
  name                 = "SQL-lB"
  mode                 = "tcp"
  port                 = 3306
  default_backend_name = resource.upcloud_loadbalancer_backend.lb_be.name
}

resource "upcloud_loadbalancer_frontend_rule" "lb_fe_rule1" {
  frontend = resource.upcloud_loadbalancer_frontend.lb_fe.id
  name     = "accept-clients"
  priority = 100

  matchers {
    src_ip {
      value = var.sql_client_ip_address
    }
  }
  actions {
    use_backend {
      backend_name = resource.upcloud_loadbalancer_backend.lb_be.name
    }
  }
}

resource "upcloud_loadbalancer_frontend_rule" "lb_fe_rule2" {
  frontend = resource.upcloud_loadbalancer_frontend.lb_fe.id
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