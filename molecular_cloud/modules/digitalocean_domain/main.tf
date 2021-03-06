##################################################################################################################
# Create a DNS pointer
##################################################################################################################
resource "digitalocean_record" "docker_swarm_node" {
  domain = "${var.domain}"
  type   = "A"
  name   = "${var.name}"
  value  = "${var.ip}"
}
