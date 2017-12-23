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
# Create worker nodes volumes
################################################################################
module "digitalocean_worker_volume" {
  source              = "../../../../modules/digitalocean_volume"
  node_type           = "worker"
  region              = "${var.region}"
  volume_size         = "${var.volume_size}"
  volume_description  = "${format("Syncthing volume for ${var.system_name}.")}"
  system_name         = "${var.system_name}"
  index               = "${var.index}"
}

################################################################################
# Create worker nodes
################################################################################
module "digitalocean_worker_node" {
  source              = "../../../../modules/digitalocean_node"
  index               = "${var.index}"
  node_type           = "worker"
  droplet_size        = "${var.droplet_size}"
  droplet_image       = "${var.droplet_image}"
  droplet_user        = "${var.droplet_user}"
  region              = "${var.region}"
  volume_id           = "${module.digitalocean_worker_volume.id}"
  volume_name         = "${module.digitalocean_worker_volume.name}"
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
module "digitalocean_worker_dns" {
  source              = "../../../../modules/digitalocean_domain"
  domain              = "${var.domain}"
  name                = "${module.digitalocean_worker_node.name}"
  ip                  = "${module.digitalocean_worker_node.ip}"
}
