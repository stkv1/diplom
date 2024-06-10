#get snapshot-id manually
variable "bastion-snapshot" {
  type = string
  description = "Введите id снапшота для машины Bastion"
}

# create image from snapshot
resource "yandex_compute_image" "image-snapshot" {
  name     = "bastion-disk-from-snapshot"
  source_snapshot = var.bastion-snapshot
}

# create boot disk
resource "yandex_compute_disk" "bastion-disk" {
  name     = "debian-12-ansible"
  type     = "network-ssd"
  zone     = "ru-central1-a"
  size     = 21
  image_id = "${yandex_compute_image.image-snapshot.id}"
}

resource "yandex_compute_instance" "vm-1" {
  name                      = "bastion-vm"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.bastion-disk.id
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta-bastion.yml")}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Destroying instance...'"
  }
}

# upload inventory from bucket
# "null_resource" only as container to use "depends_on" directive
# because "depends_on" not supported in provisioners

resource "null_resource" "example_trigger" {
  # waiting while inventory will be uploaded into bucket
  depends_on = [yandex_storage_object.test-object]
  
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
      user        = "stanislav"
      private_key = file("~/.ssh/id_rsa")
    }

    inline = [
      "aws s3 cp --endpoint-url=https://storage.yandexcloud.net s3://images-for-vm-1/inventory.yml /home/stanislav/ansible/inventory/",
    ]
  }
}