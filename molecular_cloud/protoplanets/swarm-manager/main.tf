################################################################################
# Get necessary data
################################################################################
provider "digitalocean" {
  token = "${var.do_token}"
}

################################################################################
# Create manager nodes volumes
################################################################################
module "digitalocean_manager_volume" {
  source              = "../../../../modules/digitalocean_volume"
  count               = "1"
  node_type           = "manager"
  region              = "${var.region}"
  volume_size         = "${var.volume_size}"
  volume_description  = "${format("Syncthing volume for ${var.system_name}.")}"
  system_name         = "${var.system_name}"
  index               = "${var.index}"
}

################################################################################
# Create manager nodes
################################################################################
module "digitalocean_manager_node" {
  source              = "../../../../modules/digitalocean_node"
  count               = 1
  index               = "${var.index}"
  node_type           = "manager"
  droplet_size        = "${var.do_agent_size}"
  droplet_image       = "${var.do_image}"
  droplet_user        = "${var.do_user}"
  region              = "${var.region}"
  vol_ids             = ["${module.digitalocean_manager_volume.ids}"]
  vol_names           = ["${module.digitalocean_manager_volume.names}"]
#  volume_size         = "${var.swarm_volume_size}"
#  volume_description  = "${format("Syncthing volume for ${var.swarm_name}.")}"
  public_key          = "${var.public_key}"
  ssh_key_list        = [
  "${data.terraform_remote_state.digitalocean.ssh_key_id}",
  ]
  private_key         = "${var.private_key}"
  system_name         = "${var.system_name}"
  swarm_token_dir     = "${var.swarm_token_dir}"
  manager_address     = "${file("../../../../data/hosts/${var.system_name}-00")}"
}
