terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

#set variable string for token
variable "yandex_cloud_token" {
  type = string
  description = "Введите секретный токен от yandex_cloud"
}

provider "yandex" {
  token                    = var.yandex_cloud_token
  cloud_id                 = "********************"
  folder_id                = "********************"
  zone                     = "ru-cetral1-b"
}

# Service Account. VM Groups operated only with service account
# If service account already exists, this section not needed
/*resource "yandex_iam_service_account" "terraform" {
  name        = "terraform"
  description = "service account to manage IG"
}

# Determine service account role for folder
# If service account already exists, this section not needed
resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = "********************"
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.terraform.id}"
}*/

resource "yandex_lb_target_group" "target-group-nlb" {
  name      = "my-target-group-nlb"

  target {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    address = yandex_compute_instance_group.ig-1.instances.0.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet-2.id
    address = yandex_compute_instance_group.ig-1.instances.1.network_interface.0.ip_address
  }
}

resource "yandex_alb_target_group" "target-group" {
  name = "my-target-group-alb-separate"
  
  target {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    ip_address = yandex_compute_instance_group.ig-1.instances.0.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet-2.id
    ip_address = yandex_compute_instance_group.ig-1.instances.1.network_interface.0.ip_address
  }
}

# Determine group of VM-s
resource "yandex_compute_instance_group" "ig-1" {
  name                = "fixed-ig-with-balancer"
  folder_id           = "b1gbs69rm17l1ks91fee"
  service_account_id  = "aje5o1dpmj8lpiu110m3"
  deletion_protection = false
  
  instance_template {
    platform_id = "standard-v3"
    
    resources {
      memory = 2
      cores  = 2
      core_fraction = 20
    }

    metadata = {
      user-data = "${file("./meta.yml")}"
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        # Debian 10
        image_id = "fd8n0gp0i9d7u9a5ejjk"
      }
    }

    network_interface {
      network_id = "${yandex_vpc_network.network-1.id}"
      subnet_ids = ["${yandex_vpc_subnet.subnet-1.id}","${yandex_vpc_subnet.subnet-2.id}"]
      nat = true
    }

    # create interruptible vm
    scheduling_policy {
      preemptible = true
    }
  }

  scale_policy {
    fixed_scale {
      # Количество VM в группе
      size = 2
    }
  }

  allocation_policy {
    zones = ["ru-central1-a", "ru-central1-b"]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  /*application_load_balancer {
    target_group_name = "my-target-group-alb"
    target_group_description = "load balancer target group"
  }*/
}

resource "yandex_alb_backend_group" "backend-group" {
  name                     = "backend-group"
  session_affinity {
    connection {
      source_ip = true
    }
  }

  http_backend {
    name                   = "my-http-backend"
    weight                 = 1
    port                   = 80
    target_group_ids       = ["${yandex_alb_target_group.target-group.id}"]
    load_balancing_config {
      panic_threshold      = 90
    }    
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 10
      unhealthy_threshold  = 15 
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "my-router" {
  name          = "my-router"
  labels        = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "my-virtual-host" {
  name                    = "my-virtual-host"
  http_router_id          = yandex_alb_http_router.my-router.id
  route {
    name                  = "my-route"
    http_route {
      http_route_action {
        backend_group_id  = "${yandex_alb_backend_group.backend-group.id}"
        timeout           = "60s"
      }
    }
  }
  /*route_options {
    security_profile_id   = "<идентификатор_профиля_безопасности>"
  }*/
}


resource "yandex_lb_network_load_balancer" "lb-1" {
  name = "lb-1"

  listener {
    name = "my-list"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.target-group-nlb.id
    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/index.html"
      }
    }
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}
  
resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet2"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["192.168.20.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}

