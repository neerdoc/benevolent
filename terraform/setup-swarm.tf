##################################################################################################################
# Digital ocean settings
##################################################################################################################
variable "do_token" {
  description = "Your DigitalOcean API key"
}

variable "region" {
  description = "DigitalOcean Region"
  type = "list"
  default = ["fra1", "sgp1", "nyc1"]
}

variable "do_image" {
  description = "Slug for the image to install"
  // Docker versions at this moment:
  // stable -> 1.12.6
  // beta -> 1.12.6
  // alpha -> 17.09.0
  default = "coreos-alpha"
}

variable "do_agent_size" {
  description = "Agent Droplet Size"
  default = "512mb"
}

variable "public_key" {
  description = "Path to the SSH public key"
  default = "data/do-key.pub"
}

variable "private_key" {
  description = "Path to the SSH private key"
  default = "data/do-key"
}

variable "do_user" {
  description = "User to use to connect the machine using SSH. Depends on the image being installed."
  default = "core"
}


##################################################################################################################
# Setup for local syncthing
##################################################################################################################

variable "syncthing_conf_dir" {
  description = "This is the local directory where you configure syncthing."
}

variable "syncthing_data_dir" {
  description = "This is the local directory where you want to store the data."
}

##################################################################################################################
# Setup for domain
##################################################################################################################

variable "dns_domain" {
  description = "Name of the DNS domain for the swarm"
  default = "gj2s.com"
}

variable "dns_domain_name" {
  description = "Name of the swarm in the DNS domain"
  default = "skynet"
}


##################################################################################################################
# Setup for swarm
##################################################################################################################

variable "swarm_token_dir" {
  description = "Path (on the remote machine) which contains the generated swarm tokens"
  default = "/home/core"
}

variable "swarm_name" {
  description = "Name of the cluster, used also for networking"
  default = "skynet"
}

variable "swarm_master_count" {
  description = "Number of master nodes."
  default = "1"
}

variable "swarm_agent_count" {
  description = "Number of agents to deploy"
  default = "1"
}

variable "swarm_volume_size" {
  description = "Persistent storage size in GB."
  default = "1"
}

variable "swarm_storage_path" {
  description = "Path, on each node, to the syncthing storage"
  default = "/mnt/storage"
}

variable "swarm_storage_server_name" {
  default = "mnt-storage"
}
