variable "count" {
  description = "Count of nodes."
  default = 0
}

variable "node_type" {
  description = "Type of node. manager or worker"
}

variable "volume_id" {
  description = "Place holder for volume id."
}

variable "volume_name" {
  description = "Place holder for volume name."
}

variable "manager_address" {
  description = "IP address of the initial master node."
}

variable "droplet_size" {
  description = "Size of droplet."
}

variable "droplet_image" {
  description = "Image to build droplet from."
}

variable "droplet_user" {
  description = "User that logs into the container. Depends on image."
}

variable "region" {
  description = "Region of droplet."
}

variable "swarm_token_dir" {
  description = "Directory to store token on remote host."
}

variable "public_key" {
  description = "Public key."
}

variable "private_key" {
  description = "Private key."
}

variable "system_name" {
  description = "Name of the swarm."
}

variable "ssh_key_list" {
  description = "List of approved ssh keys."
  type        = "list"
}

variable "index" {
  description = "Index number of the node."
}
