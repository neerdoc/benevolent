output "ip" {
  value = "${digitalocean_droplet.docker_swarm_node.ipv4_address}"
}
output "name" {
  value = "${digitalocean_droplet.docker_swarm_node.name}"
}
