##################################################################################################################
# Create the disk
##################################################################################################################
resource "digitalocean_volume" "bedrock" {
  region      = "${var.region}"
  name        = "${format("${var.system_name}-bedrock-${var.node_type}-${var.index}")}"
  size        = "${var.volume_size}"
  description = "${var.volume_description}"
}
