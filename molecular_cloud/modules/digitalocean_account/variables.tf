##################################################################################################################
# Digital ocean settings
##################################################################################################################
variable "do_token" {
  description = "Your DigitalOcean API key"
}

variable "public_key" {
  description = "Path to the SSH public key"
  default = "data/do-key.pub"
}

variable "swarm_name" {
  description = "Name of swarm."
}
