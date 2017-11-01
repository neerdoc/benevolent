output "ip_address" {
  value = "${digitalocean_droplet.docker_swarm_init_node.ipv4_address}"
}
