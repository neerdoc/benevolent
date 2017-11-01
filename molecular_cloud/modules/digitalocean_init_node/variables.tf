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

variable "ssh_key_list" {
  description = "List of approved ssh keys."
  type        = "list"
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

variable "index" {
  description = "Index number of the node."
}
