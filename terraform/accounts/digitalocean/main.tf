##################################################################################################################
# SSH Key
##################################################################################################################
resource "digitalocean_ssh_key" "docker_swarm_ssh_key" {
  name = "${var.swarm_name}-ssh-key"
  public_key = "${file("../../${var.public_key}")}"
}

provider "digitalocean" {
  token = "${var.do_token}"
}
