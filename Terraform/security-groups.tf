resource "yandex_vpc_security_group" "balancer-sg" {
  name        = "balancer-sg"
  description = "security group for balancer"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    description    = "80 tcp ingress"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "443 tcp ingress"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24"]
    port           = 443
  }

   ingress {
    protocol       = "TCP"
    description    = "balancer healthcheck"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24"]
    port           = 30080
  }

  ingress {
    protocol          = "ANY"
    description       = "Разрешает взаимодействие между ресурсами текущей группы безопасности"
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }

  egress {
    protocol       = "ANY"
    description    = "Outgoing traffic from balancer to web-server vm group"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "zabbix-sg" {
  name        = "zabbix-sg"
  description = "security group for zabbix server"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    description    = "80 tcp ingress"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "443 tcp ingress"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 443
  }

  ingress {
    protocol       = "TCP"
    description    = "10050 tcp ingress"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 10050
  }

  egress {
    protocol       = "ANY"
    description    = "Outgoing traffic"
    v4_cidr_blocks = ["192.168.10.0/24"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "kibana-sg" {
  name        = "kibana-sg"
  description = "security group for zabbix server"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    description    = "5601 kibana interface"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 5601
  }

  ingress {
    protocol       = "TCP"
    description    = "9200 from elasticsearch"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 9200
  }

  egress {
    protocol       = "TCP"
    description    = "9200 to elasticsearch"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 9200
  }
}