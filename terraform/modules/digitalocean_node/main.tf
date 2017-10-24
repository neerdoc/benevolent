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

##################################################################################################################
# Create the droplet
##################################################################################################################
resource "digitalocean_droplet" "docker_swarm_node" {
  count       = "${var.count}"
  name        = "${format("${var.swarm_name}-${var.node_type}-%02d", count.index)}"
  size        = "${var.droplet_size}"
  image       = "${var.droplet_image}"
  region      = "${element(var.region, count.index)}"
  volume_ids  = ["${element(digitalocean_volume.bedrock.*.id, count.index)}"]
  ssh_keys    = ["${var.ssh_key_list}"]
  user_data   = <<EOF
#cloud-config

ssh_authorized_keys:
  - "${file("../../${var.public_key}")}"
coreos:
  units:
    - name: rpc-statd.service
      command: start
      enable: true
EOF

  #Hm... we will see...
  private_networking = false

  connection {
    user        = "${var.droplet_user}"
    private_key = "${file("../../${var.private_key}")}"
    agent       = false
  }

  #########################
  # Setup ssh connections
  #########################
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/../../data/hosts && printf ${self.ipv4_address} > ${path.module}/../../data/hosts/${self.name}"
  }
  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -fr ${path.module}/../../data/hosts/${self.name}"
  }

  #########################
  # Connect to docker swarm
  #########################
  provisioner "file" {
    source = "../../data/manager.token"
    destination = "${var.swarm_token_dir}/manager.token"
  }
  provisioner "file" {
    source = "../../data/worker.token"
    destination = "${var.swarm_token_dir}/worker.token"
  }

  provisioner "remote-exec" {
    inline = [
      "docker swarm join --token $(cat ${var.swarm_token_dir}/${var.node_type}.token) ${var.manager_address}:2377"
    ]
  }

  provisioner "remote-exec" {
    when    = "destroy"
    inline = [
      "docker swarm leave --force"
    ]
  }

  #########################
  # Setup the volume
  #########################
  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 -F /dev/disk/by-id/scsi-0DO_Volume_${element(digitalocean_volume.bedrock.*.name, count.index)}",
      "sudo mkdir -p /mnt/storage",
      "sudo mount -o discard,defaults /dev/disk/by-id/scsi-0DO_Volume_${element(digitalocean_volume.bedrock.*.name, count.index)} /mnt/storage",
      "echo /dev/disk/by-id/scsi-0DO_Volume_${element(digitalocean_volume.bedrock.*.name, count.index)} /mnt/storage ext4 defaults,nofail,discard 0 0 | sudo tee -a /etc/fstab"
    ]
  }
}
