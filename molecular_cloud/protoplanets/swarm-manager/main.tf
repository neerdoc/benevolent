################################################################################
# Get necessary data
################################################################################
provider "digitalocean" {
  token = "${var.do_token}"
}
# We need data from the account setup
data "terraform_remote_state" "digitalocean" {
  backend = "local"
  config {
    path = "../../account/00/terraform.tfstate"  }
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
  droplet_size        = "${var.droplet_size}"
  droplet_image       = "${var.droplet_image}"
  droplet_user        = "${var.droplet_user}"
  region              = "${var.region}"
  volume_id           = "${module.digitalocean_manager_volume.id}"
  volume_name         = "${module.digitalocean_manager_volume.name}"
  public_key          = "${var.public_key}"
  ssh_key_list        = [
  "${data.terraform_remote_state.digitalocean.ssh_key_id}",
  ]
  private_key         = "${var.private_key}"
  system_name         = "${var.system_name}"
  swarm_token_dir     = "${var.swarm_token_dir}"
  manager_address     = "${file("../../../../data/hosts/${var.system_name}-00")}"
}

################################################################################
# Create DNS records
################################################################################
module "digitalocean_manager_dns" {
  source              = "../../../../modules/digitalocean_domain"
  domain              = "${var.domain}"
  name                = "${module.digitalocean_manager_node.name}"
  ip                  = "${module.digitalocean_manager_node.ip}"
}
