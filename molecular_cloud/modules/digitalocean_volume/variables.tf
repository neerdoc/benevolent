variable "count" {
  description = "Count of nodes."
  default = 0
}

variable "node_type" {
  description = "Type of node. manager or worker"
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

variable "swarm_name" {
  description = "Name of the swarm."
}
