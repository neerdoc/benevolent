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
    path = "../../account/00/terraform.tfstate"  }
}

module "digitalocean_init_manager_node" {
  source = "../../../../modules/digitalocean_init_node"

  # Set variables
  droplet_size        = "${var.droplet_size}"
  droplet_image       = "${var.droplet_image}"
  droplet_user        = "${var.droplet_user}"
  index               = "${var.index}"
  region              = "${var.region}"
  public_key          = "${var.public_key}"
  ssh_key_list        = [
    "${data.terraform_remote_state.digitalocean.ssh_key_id}",
  ]
  private_key         = "${var.private_key}"
  system_name         = "${var.system_name}"
  swarm_token_dir     = "${var.swarm_token_dir}"
}
