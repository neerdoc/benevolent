output "id" {
  value = "${digitalocean_droplet.docker_swarm_node.*.id}"
}

output "bedrock_id" {
  value = "${digitalocean_volume.bedrock.*.id}"
}


output "bedrock_id_00" {
  value = "${digitalocean_volume.bedrock.0.id}"
}
