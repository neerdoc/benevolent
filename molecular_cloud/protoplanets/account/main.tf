################################################################################
# Setup an SSH Key for DigtialOcean
################################################################################
provider "digitalocean" {
  token = "${var.do_token}"
}
resource "digitalocean_ssh_key" "docker_swarm_ssh_key" {
  name = "${var.system_name}-ssh-key"
  public_key = "${file("${var.public_key}")}"
#  public_key = "${file("../../${var.public_key}")}"
}
