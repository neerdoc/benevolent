variable "count" {
  description = "Count of nodes."
  default = 0
}

#variable "initial" {
#  description = "Set to true if this is the first master node."
#  default     = false
#}

#variable "master" {
#  description = "Set to true if this is a master node."
#  default     = false
#}

variable "node_type" {
  description = "Type of node. manager or worker"
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
  type        = "list"
}

variable "volume_size" {
  description = "Size of persistent disk in GB."
  default     = 1
}

variable "volume_description" {
  description = "Description of volume."
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

variable "swarm_name" {
  description = "Name of the swarm."
}

variable "ssh_key_list" {
  description = "List of approved ssh keys."
  type        = "list"
}
