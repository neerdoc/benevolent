##################################################################################################################
# Get necessary data
##################################################################################################################
provider "digitalocean" {
  token = "${var.do_token}"
}

# We need data from the account setup
data "terraform_remote_state" "digitalocean" {
  backend = "local"
  config {
    path = "${path.module}/../../accounts/digitalocean/terraform.tfstate"  }
}

##################################################################################################################
# Create permanent manager nodes volumes
##################################################################################################################
module "digitalocean_manager_volume" {
  source = "../../modules/digitalocean_volume"
  count               = "${var.swarm_manager_count}"
  node_type           = "manager"
  region              = "${var.region}"
  volume_size         = "${var.swarm_volume_size}"
  volume_description  = "${format("Syncthing volume for ${var.swarm_name}.")}"
  swarm_name          = "${var.swarm_name}"
}

##################################################################################################################
# Create permanent manager nodes
##################################################################################################################
module "digitalocean_manager_node" {
  source = "../../modules/digitalocean_node"

  count               = "${var.swarm_manager_count}"
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
  swarm_name          = "${var.swarm_name}"
  swarm_token_dir     = "${var.swarm_token_dir}"
  manager_address     = "${file("../../data/hosts/${var.swarm_name}-temp-manager-00")}"
}

##################################################################################################################
# Create permanent worker nodes volumes
##################################################################################################################
module "digitalocean_worker_volume" {
  source = "../../modules/digitalocean_volume"
  count               = "${var.swarm_worker_count}"
  node_type           = "worker"
  region              = "${var.region}"
  volume_size         = "${var.swarm_volume_size}"
  volume_description  = "${format("Syncthing volume for ${var.swarm_name}.")}"
  swarm_name          = "${var.swarm_name}"
}

##################################################################################################################
# Create worker nodes
##################################################################################################################
module "digitalocean_worker_node" {
  source = "../../modules/digitalocean_node"

  count               = "${var.swarm_worker_count}"
  node_type           = "worker"
  droplet_size        = "${var.do_agent_size}"
  droplet_image       = "${var.do_image}"
  droplet_user        = "${var.do_user}"
  region              = "${var.region}"
  vol_ids             = ["${module.digitalocean_worker_volume.ids}"]
  vol_names           = ["${module.digitalocean_worker_volume.names}"]
#  volume_size         = "${var.swarm_volume_size}"
#  volume_description  = "${format("Syncthing volume for ${var.swarm_name}.")}"
  public_key          = "${var.public_key}"
  ssh_key_list        = [
  "${data.terraform_remote_state.digitalocean.ssh_key_id}",
  ]
  private_key         = "${var.private_key}"
  swarm_name          = "${var.swarm_name}"
  swarm_token_dir     = "${var.swarm_token_dir}"
  manager_address     = "${file("../../data/hosts/${var.swarm_name}-temp-manager-00")}"
}
