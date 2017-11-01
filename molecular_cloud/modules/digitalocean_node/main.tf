##################################################################################################################
# Create the droplet
##################################################################################################################
resource "digitalocean_droplet" "docker_swarm_node" {
  count       = "${var.count}"
  region      = "${var.region}"
  name        = "${format("${var.system_name}-${var.node_type}-${var.index}")}"
  description = "${var.droplet_description}"
  size        = "${var.droplet_size}"
  image       = "${var.droplet_image}"
#  volume_ids  = ["${element(var.vol_ids, count.index)}"]
#  volume_ids  = ["${var.vol_ids}"]
#  volume_ids  = ["${digitalocean_manager_volume.*.id[count.index]}"]
#  vol_id      = "${digitalocean_volume.bedrock.*.id[count.index]}"
#  vol_name    = "${digitalocean_volume.bedrock.*.name[count.index]}"
#  volume_ids  = ["${var.vol_id}"]
#  volume_ids  = ["${data.template_file.init.rendered}"]
#  volume_ids  = ["${digitalocean_volume.bedrock.*.id[count.index]}"]
#  volume_ids  = ["${digitalocean_volume.bedrock.[count.index].id}"]
  ssh_keys    = ["${var.ssh_key_list}"]
  user_data   = <<EOF
#cloud-config

ssh_authorized_keys:
  - "${file("../../../../${var.public_key}")}"
coreos:
  units:
    - name: rpc-statd.service
      command: start
      enable: true
EOF

  private_networking = false
  connection {
    user        = "${var.droplet_user}"
    private_key = "${file("../../../../${var.private_key}")}"
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
#  provisioner "remote-exec" {
#    inline = [
#      "sudo mkfs.ext4 -F /dev/disk/by-id/scsi-0DO_Volume_${element(var.vol_names, count.index)}",
#      "sudo mkdir -p /mnt/storage",
#      "sudo mount -o discard,defaults /dev/disk/by-id/scsi-0DO_Volume_${element(var.vol_names, count.index)} /mnt/storage",
#      "echo /dev/disk/by-id/scsi-0DO_Volume_${element(var.vol_names, count.index)} /mnt/storage ext4 defaults,nofail,discard 0 0 | sudo tee -a /etc/fstab"
#    ]
#  }

  #########################
  # Destroy stuff
  #########################
  provisioner "remote-exec" {
    when    = "destroy"
    inline = [
      "docker swarm leave --force && sleep 10"
    ]
  }
  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -fr ../../../../data/hosts/${self.name}"
  }
}
