output "ip_address" {
  value = "${digitalocean_droplet.docker_swarm_temp_node.ipv4_address}"
}
