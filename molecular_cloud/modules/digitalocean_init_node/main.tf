##################################################################################################################
# Create the droplet
##################################################################################################################
resource "digitalocean_droplet" "docker_swarm_init_node" {
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
      - name: iptables-restore.service
        enable: true
        command: start
      - name: docker.service
        command: start
        enable: true
write_files:
  - path: /var/lib/iptables/rules-save
    permissions: 0644
    owner: 'root:root'
    content: |
      *filter
      :INPUT DROP [0:0]
      :FORWARD DROP [0:0]
      :OUTPUT ACCEPT [0:0]
      # Accept all loopback (local) traffic:
      -A INPUT -i lo -j ACCEPT

      # Accept all traffic on the local network from other members of
      # REMOVED: Since we have no priavte network, disable this.
      #-A INPUT -i eth1 -j ACCEPT

      # Keep existing connections (like our SSH session) alive:
      -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

      # Accept all TCP/IP traffic to SSH, HTTP, and HTTPS ports - this should
      # be customized  for your application:
      -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
      -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
      -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT

      # Accept pings:
      -A INPUT -p icmp -m icmp --icmp-type 0 -j ACCEPT
      -A INPUT -p icmp -m icmp --icmp-type 3 -j ACCEPT
      -A INPUT -p icmp -m icmp --icmp-type 11 -j ACCEPT

      # Accept connections for syncthing
      -A INPUT -p tcp -m tcp --dport 21000 -j ACCEPT

      # Open up for docker swarm
      -A INPUT -p tcp -m tcp --dport 2377 -j ACCEPT
      -A INPUT -p tcp -m tcp --dport 7946 -j ACCEPT
      -A INPUT -p udp -m udp --dport 7946 -j ACCEPT
      -A INPUT -p udp -m udp --dport 4789 -j ACCEPT


      COMMIT
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
  # Make sure another node can be reached as master!
  provisioner "local-exec" {
    when = "destroy"
    command = "rm -fr ../../../../data/hosts/${self.name} && find ../../../../data/hosts/ -name '${var.system_name}-*er-*' -exec cat {} > ../../../../data/hosts/${self.name} \\; -quit"
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
      "docker node demote ${self.name}|| :",
      "docker swarm leave --force || :",
      "docker node rm ${self.name}|| :"
    ]
  }
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -i ${var.private_key} ${var.droplet_user}@${self.ipv4_address}:${var.swarm_token_dir}/worker.token ../../../../data/"
  }
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -i ${var.private_key} ${var.droplet_user}@${self.ipv4_address}:${var.swarm_token_dir}/manager.token ../../../../data/"
    }
}
