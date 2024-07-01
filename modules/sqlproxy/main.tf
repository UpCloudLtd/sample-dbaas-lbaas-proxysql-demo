resource "upcloud_server" "sql-proxy-server" {
  zone       = var.zone
  plan       = var.sqlproxy_plan
  count      = 2
  metadata   = true
  hostname   = "sql-proxy${count.index}-server"
  depends_on = [var.private_sdn_network_proxysql, var.dbaas_mysql_hosts]

  template {
    storage = "Ubuntu Server 22.04 LTS (Jammy Jellyfish)"
    size    = 25
  }

  network_interface {
    type = "public"
  }
  network_interface {
    type    = "private"
    network = var.private_sdn_network_proxysql
  }
  network_interface {
    type    = "private"
    network = var.private_sdn_network_be
  }
  login {
    user = "root"
    keys = [
      var.ssh_key_public,
    ]
    create_password   = false
    password_delivery = "email"
  }

  connection {
    host  = self.network_interface[0].ip_address
    type  = "ssh"
    user  = "root"
    agent = true
  }

  provisioner "file" {
    content = templatefile("configs/proxysql-setup.sql.tftpl",
      {
        SERVER0                = var.dbaas_mysql_hosts[0],
        SERVER1                = var.dbaas_mysql_hosts[1],
        DBAAS_USER             = var.dbaas_mysql_username,
        DBAAS_PASSWORD         = var.dbaas_mysql_password,
        DBAAS_MONITOR_USER     = var.dbaas_mysql_monitor_username,
        DBAAS_MONITOR_PASSWORD = var.dbaas_mysql_monitor_password,
        DBAAS_PORT             = var.dbaas_mysql_port
    })
    destination = "/root/proxysql-setup.sql"
  }

  provisioner "remote-exec" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "apt-get -o 'Dpkg::Options::=--force-confold' -q -y install --no-install-recommends lsb-release wget apt-transport-https ca-certificates gnupg",
      "wget -O - 'https://repo.proxysql.com/ProxySQL/proxysql-2.5.x/repo_pub_key' | apt-key add -",
      "echo deb https://repo.proxysql.com/ProxySQL/proxysql-2.5.x/$(lsb_release -sc)/ ./ | tee /etc/apt/sources.list.d/proxysql.list",
      "apt-get -o 'Dpkg::Options::=--force-confold' -q -y update",
      "apt-get -o 'Dpkg::Options::=--force-confold' -q -y install proxysql mysql-client-core-8.0",
      "systemctl enable --now proxysql",
      "echo 'mysql -u admin -p${var.dbaas_mysql_password} -h 127.0.0.1 -P6032 -e \"select hostgroup, schemaname, username, digest, digest_text, count_star from stats_mysql_query_digest;\"' > /root/show-query-digest.sh",
      "echo 'mysql -u admin -p${var.dbaas_mysql_password} -h 127.0.0.1 -P6032 -e \"select * from mysql_servers;\"' > /root/show-servers.sh",
      "echo 'mysql -u admin -p${var.dbaas_mysql_password} -h 127.0.0.1 -P6032 -e \"select * from mysql_query_rules;\"' > /root/show-rules.sh",
      "echo 'cat /root/proxysql-setup.sql | mysql -uadmin -padmin -h127.0.0.1 -P6032' > /root/finish.sh",
      "exit 0"
    ]
  }
  provisioner "remote-exec" {
    inline = ["bash /root/finish.sh"]
  }
}

resource "upcloud_server_group" "proxy-ha-pair" {
  title                = "proxy_ha_group"
  anti_affinity_policy = "yes"
  labels = {
    "key1" = "proxy-ha"

  }
  members = [
    upcloud_server.sql-proxy-server[0].id,
    upcloud_server.sql-proxy-server[1].id
  ]

}