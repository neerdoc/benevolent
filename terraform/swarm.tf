##################################################################################################################
# SSH Key
##################################################################################################################
resource "digitalocean_ssh_key" "docker_swarm_ssh_key" {
  name = "${var.swarm_name}-ssh-key"
  public_key = "${file(var.do_ssh_key_public)}"
}

##################################################################################################################
# Local syncthing server
##################################################################################################################
module "syncthing_local" {
  source = "modules/syncthing"
  # Need to remap environmental variables to module input.
  conf_dir = "${var.syncthing_conf_dir}"
  data_dir = "${var.syncthing_data_dir}"
  gui = true
}

##################################################################################################################
# Initial master node, i.e., local
##################################################################################################################
# Create a local swarm master if it doesn't already exist!
module "docker_swarm_master" {
  source = "modules/docker_swarm_local"
}

##################################################################################################################
# Additional master nodes
##################################################################################################################
module "digitalocean_master_nodes" {
  source = "modules/digitalocean_node"

  # Set variables
  count               = 3
  master              = true
  droplet_size        = "${var.do_agent_size}"
  droplet_image       = "${var.do_image}"
  droplet_user        = "${var.do_user}"
  region              = "${var.region}"
  volume_size         = "${var.swarm_volume_size}"
  volume_description  = "${format("Syncthing volume for ${var.swarm_name}.")}"
  public_key          = "${var.do_ssh_key_public}"
  ssh_key_list        = [
    "${digitalocean_ssh_key.docker_swarm_ssh_key.id}",
  ]
  private_key         = "${var.do_ssh_key_private}"
  swarm_name          = "${var.swarm_name}"
  swarm_token_dir     = "${var.swarm_token_dir}"
}
