##################################################################################################################
# Create the droplet
##################################################################################################################
resource "digitalocean_droplet" "docker_swarm_init_node" {
  count       = 1
  name        = "${format("${var.system_name}-${var.index}")}"
  size        = "${var.droplet_size}"
  image       = "${var.droplet_image}"
  region      = "${var.region}"
  ssh_keys    = ["${var.ssh_key_list}"]
  user_data   = <<EOF
#cloud-config

ssh_authorized_keys:
  - "${file("${var.public_key}")}"
coreos:
  units:
    - name: rpc-statd.service
      command: start
      enable: true
EOF

  private_networking = false
  connection {
    user        = "${var.droplet_user}"
    private_key = "${file("${var.private_key}")}"
    agent       = false
  }

  #########################
  # Setup ssh connections
  #########################
  provisioner "local-exec" {
    command = "mkdir -p ../../../../data/hosts && printf ${self.ipv4_address} > ../../../../data/hosts/${self.name}"
  }

  #########################
  # Create docker swarm
  #########################
  provisioner "remote-exec" {
    inline = [
      "docker swarm init --advertise-addr ${self.ipv4_address}",
      "docker swarm join-token --quiet worker > ${var.swarm_token_dir}/worker.token",
      "docker swarm join-token --quiet manager > ${var.swarm_token_dir}/manager.token"
    ]
  }
  provisioner "remote-exec" {
    when    = "destroy"
    inline = [
      "docker swarm leave --force && sleep 10"
    ]
  }
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -i ${var.private_key} ${var.droplet_user}@${self.ipv4_address}:${var.swarm_token_dir}/worker.token ../../../../data/"
  }
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -i ${var.private_key} ${var.droplet_user}@${self.ipv4_address}:${var.swarm_token_dir}/manager.token ../../../../data/"
    }
}
