output "ssh_key_id" {
  value = "${digitalocean_ssh_key.docker_swarm_ssh_key.id}"
}
