output "ids" {
  value = "${digitalocean_volume.bedrock.*.id}"
}
output "names" {
  value = "${digitalocean_volume.bedrock.*.name}"
}
