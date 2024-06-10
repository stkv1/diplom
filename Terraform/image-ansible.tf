# create compute cloud image from image, downloaded from bucket
resource "yandex_compute_image" "image-1" {
  name       = "debian-12-ansible-image"
  os_type    = "LINUX"
  source_url = "https://storage.yandexcloud.net/images-for-vm-1/vm1_snap_copy-flat.vmdk?***-Amz-SignedHeaders=host"
  pooled     = "false"
}