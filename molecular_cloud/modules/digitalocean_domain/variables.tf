#variable "count" {
#  description = "Count of nodes."
#  default = 0
#}

variable "domain" {
  description = "Domain name to create DNS records for."
}
variable "name" {
  description = "Name of dns record."
}
variable "ip" {
  description = "IP-adress of dns record."
}
