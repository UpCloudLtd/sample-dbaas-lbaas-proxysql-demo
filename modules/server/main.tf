resource "upcloud_server" "sql-client" {
  hostname   = "sql-client"
  zone       = var.zone
  plan       = "2xCPU-4GB"
  depends_on = [var.private_sdn_network, var.dbaas_mysql_username]

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

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get -y install sysbench mysql-client-core-8.0",
      "echo 'sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=$1 --threads=4 --mysql-user=${var.dbaas_mysql_username} --mysql-password=${var.dbaas_mysql_password} --mysql-port=$2 --mysql-db=${var.dbaas_mysql_database} --db-driver=mysql --tables=10 --table-size=100000 --db-ps-mode=disable --skip-trx --point-selects=100 --simple-ranges=1 --sum-ranges=1 --order-ranges=1 --distinct-ranges=1 prepare' > /root/prepare-benchmark",
      "echo 'sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=$1 --threads=40 --mysql-user=${var.dbaas_mysql_username} --mysql-password=${var.dbaas_mysql_password} --mysql-port=$2 --mysql-db=${var.dbaas_mysql_database} --db-driver=mysql --tables=10 --table-size=100000 --report-interval=10 --time=60 --db-ps-mode=disable --skip-trx --point-selects=100 --simple-ranges=1 --sum-ranges=1 --order-ranges=1 --distinct-ranges=1 --mysql-ignore-errors=1062,1213 run' > /root/run-readwrite-benchmark",
      "echo 'sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=$1 --threads=40 --mysql-user=${var.dbaas_mysql_username} --mysql-password=${var.dbaas_mysql_password} --mysql-port=$2 --mysql-db=${var.dbaas_mysql_database} --db-driver=mysql --tables=10 --table-size=100000 --report-interval=10 --time=60 --db-ps-mode=disable --skip-trx --point-selects=100 --simple-ranges=1 --sum-ranges=1 --order-ranges=1 --distinct-ranges=1 run' > /root/run-readonly-benchmark",
      "echo 'sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=$1 --threads=4 --mysql-user=${var.dbaas_mysql_username} --mysql-password=${var.dbaas_mysql_password} --mysql-port=$2 --mysql-db=${var.dbaas_mysql_database} --db-driver=mysql --tables=10 --table-size=100000  cleanup' > /root/cleanup-benchmark",
      "echo 'while true; do mysql -h $1 -P$2 -u${var.dbaas_mysql_username} -p${var.dbaas_mysql_password} -srNe \"SELECT @@hostname\"; sleep 1; done' > /root/ping-mysql.sh"
    ]
  }
}

