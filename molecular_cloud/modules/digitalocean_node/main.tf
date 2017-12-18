##################################################################################################################
# Create the droplet
##################################################################################################################
resource "digitalocean_droplet" "docker_swarm_node" {
  count       = "${var.count}"
  region      = "${var.region}"
  name        = "${format("${var.system_name}-${var.node_type}-${var.index}")}"
  size        = "${var.droplet_size}"
  image       = "${var.droplet_image}"
  volume_ids  = ["${var.volume_id}"]
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
  # Connect to docker swarm
  #########################
  provisioner "file" {
    source = "../../../../data/manager.token"
    destination = "${var.swarm_token_dir}/manager.token"
  }
  provisioner "file" {
    source = "../../../../data/worker.token"
    destination = "${var.swarm_token_dir}/worker.token"
  }

  provisioner "remote-exec" {
    inline = [
      "docker swarm join --token $(cat ${var.swarm_token_dir}/${var.node_type}.token) ${var.manager_address}:2377"
    ]
  }


  #########################
  # Setup the volume
  #########################
  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 -F /dev/disk/by-id/scsi-0DO_Volume_${var.volume_name}",
      "sudo mkdir -p /mnt/storage",
      "sudo mount -o discard,defaults /dev/disk/by-id/scsi-0DO_Volume_${var.volume_name} /mnt/storage",
      "echo /dev/disk/by-id/scsi-0DO_Volume_${var.volume_name} /mnt/storage ext4 defaults,nofail,discard 0 0 | sudo tee -a /etc/fstab",
      "sudo chown -R core:core /mnt/storage"
    ]
  }

  #########################
  # Destroy stuff
  #########################
  provisioner "remote-exec" {
    when    = "destroy"
    inline = [
      "docker node demote ${self.name}",
      "docker swarm leave --force || true",
      "sleep 10"
    ]
  }
  # Make sure another node can be reached as master!
  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -fr ../../../../data/hosts/${self.name} && find ../../../../data/hosts/ -name '${var.system_name}-*er-*' -exec cat {} > ../../../../data/hosts/${var.system_name}-00 \\; -quit"
  }
}
