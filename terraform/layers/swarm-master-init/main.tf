##################################################################################################################
# Create a temporary master node
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

module "digitalocean_temp_manager_node" {
  source = "../../modules/digitalocean_temp_node"

  # Set variables
  droplet_size        = "${var.do_agent_size}"
  droplet_image       = "${var.do_image}"
  droplet_user        = "${var.do_user}"
  region              = "${var.region}"
  public_key          = "${var.public_key}"
  ssh_key_list        = [
    "${data.terraform_remote_state.digitalocean.ssh_key_id}",
  ]
  private_key         = "${var.private_key}"
  swarm_name          = "${var.swarm_name}"
  swarm_token_dir     = "${var.swarm_token_dir}"
}
