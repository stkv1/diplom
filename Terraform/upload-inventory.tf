#set variable string for token
variable "bucket_key" {
  type = string
  description = "Введите Идентификатор ключа"
}

#set variable string for token
variable "bucket_secret_key" {
  type = string
  description = "Введите Ваш секретный ключ"
}

# create inventory from outputs, using template
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl",
  {
      host1 = yandex_compute_instance_group.ig-1.instances.0.fqdn
      host2 = yandex_compute_instance_group.ig-1.instances.1.fqdn
      zabbix-server = yandex_compute_instance.zabbix-server.fqdn
      elastic = yandex_compute_instance.elastic.fqdn
      kibana = yandex_compute_instance.kibana.fqdn
  }
  )
  filename = "inventory.txt"
}

resource "yandex_storage_object" "test-object" {
  access_key = var.bucket_key
  secret_key = var.bucket_secret_key
  bucket     = "images-for-vm-1"
  key        = "inventory.yml"
  source     = "${path.module}/inventory.txt"
  depends_on = [local_file.ansible_inventory]
}