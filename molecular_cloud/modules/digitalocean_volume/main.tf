##################################################################################################################
# Create the disk
##################################################################################################################
resource "digitalocean_volume" "bedrock" {
  count       = "${var.count}"
  region      = "${element(var.region, count.index)}"
  name        = "${format("${var.swarm_name}-bedrock-${var.node_type}-%02d", count.index)}"
  size        = "${var.volume_size}"
  description = "${var.volume_description}"
}
