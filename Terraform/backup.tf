resource "yandex_compute_snapshot_schedule" "my-shedule" {
  name = "my-shedule"

  schedule_policy {
    expression = "@daily"
  }

  snapshot_count = 7

  snapshot_spec {
    description = "bastion host snapshot"
    labels = {
      #<ключ_метки_снимка> = "<значение_метки_снимка>"
    }
  }

  disk_ids = [
    yandex_compute_disk.bastion-disk.id,
    yandex_compute_disk.elastic-disk.id,
    yandex_compute_disk.kibana-disk.id,
    yandex_compute_disk.zabbix-disk.id
    ]
}