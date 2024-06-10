resource "yandex_compute_disk" "elastic-disk" {
  name     = "elastic-disk"
  type     = "network-ssd"
  zone     = "ru-central1-a"
  size     = 10
  image_id = "fd8n0gp0i9d7u9a5ejjk"
}

resource "yandex_compute_instance" "elastic" {
  name                      = "elastic"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
  }

  boot_disk {
    disk_id = yandex_compute_disk.elastic-disk.id
  }
  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data = "${file("./meta-elastic.yml")}"
  }
}