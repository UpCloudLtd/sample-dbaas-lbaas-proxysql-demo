resource "upcloud_server" "sql-proxy-server" {
  zone       = var.zone
  plan       = var.sqlproxy_plan
  count      = 2
  hostname   = "sql-proxy${count.index}-server"
  depends_on = [var.private_sdn_network, var.dbaas_mysql_hosts]

  template {
    storage = "Ubuntu Server 20.04 LTS (Focal Fossa)"
    size    = 25
  }

  network_interface {
    type = "public"
  }
  network_interface {
    type = "utility"
  }
  network_interface {
    type    = "private"
    network = var.private_sdn_network
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
      "apt-get install -y lsb-release",
      "wget -O - 'https://repo.proxysql.com/ProxySQL/repo_pub_key' | apt-key add -",
      "echo deb https://repo.proxysql.com/ProxySQL/proxysql-2.2.x/$(lsb_release -sc)/ ./ | tee /etc/apt/sources.list.d/proxysql.list",
      "apt-get update",
      "apt-get -y install proxysql mysql-client",
      "systemctl enable --now proxysql",
      "echo 'mysql -u admin -p${var.dbaas_mysql_password} -h 127.0.0.1 -P6032 -e \"select hostgroup, schemaname, username, digest, digest_text, count_star from stats_mysql_query_digest;\"' > /root/show-query-digest.sh",
      "echo 'mysql -u admin -p${var.dbaas_mysql_password} -h 127.0.0.1 -P6032 -e \"select * from mysql_servers;\"' > /root/show-servers.sh",
      "echo 'mysql -u admin -p${var.dbaas_mysql_password} -h 127.0.0.1 -P6032 -e \"select * from mysql_query_rules;\"' > /root/show-rules.sh",
      "echo 'cat /root/proxysql-setup.sql | mysql -uadmin -padmin -h127.0.0.1 -P6032' > /root/finish.sh",
      "exit 0"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "bash /root/finish.sh",
      "wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb",
      "sudo dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb",
      "sudo apt-get update",
      "sudo apt-get install pmm2-client"
    ]
  }
}
