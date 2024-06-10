output "fqdn1" {
  value = yandex_compute_instance_group.ig-1.instances.0.fqdn
}
output "fqdn2" {
  value = yandex_compute_instance_group.ig-1.instances.1.fqdn
}

output "ip1"{
  value = yandex_compute_instance_group.ig-1.instances.0.network_interface.0.nat_ip_address
}
output "ip2"{
  value = yandex_compute_instance_group.ig-1.instances.1.network_interface.0.nat_ip_address
}