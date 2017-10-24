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
# Create permanent manager nodes
##################################################################################################################
module "digitalocean_manager_node" {
  source = "../../modules/digitalocean_node"

  count               = 3
  node_type           = "manager"
  droplet_size        = "${var.do_agent_size}"
  droplet_image       = "${var.do_image}"
  droplet_user        = "${var.do_user}"
  region              = "${var.region}"
  volume_size         = "${var.swarm_volume_size}"
  volume_description  = "${format("Syncthing volume for ${var.swarm_name}.")}"
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
# Create worker nodes
##################################################################################################################
module "digitalocean_worker_node" {
  source = "../../modules/digitalocean_node"

  count               = 3
  node_type           = "worker"
  droplet_size        = "${var.do_agent_size}"
  droplet_image       = "${var.do_image}"
  droplet_user        = "${var.do_user}"
  region              = "${var.region}"
  volume_size         = "${var.swarm_volume_size}"
  volume_description  = "${format("Syncthing volume for ${var.swarm_name}.")}"
  public_key          = "${var.public_key}"
  ssh_key_list        = [
  "${data.terraform_remote_state.digitalocean.ssh_key_id}",
  ]
  private_key         = "${var.private_key}"
  swarm_name          = "${var.swarm_name}"
  swarm_token_dir     = "${var.swarm_token_dir}"
  manager_address     = "${file("../../data/hosts/${var.swarm_name}-temp-manager-00")}"
}
