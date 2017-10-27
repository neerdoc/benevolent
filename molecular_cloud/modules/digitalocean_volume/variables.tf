variable "count" {
  description = "Count of nodes."
}

variable "node_type" {
  description = "Type of node. manager or worker"
}

variable "region" {
  description = "Region of droplet."
}

variable "volume_size" {
  description = "Size of persistent disk in GB."
}

variable "volume_description" {
  description = "Description of volume."
}

variable "system_name" {
  description = "Name of the swarm."
}

variable "index" {
  description = "Index number of the node."
}
