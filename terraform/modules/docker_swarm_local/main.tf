# Create the swarm
resource "null_resource" "docker_swarm_master" {
provisioner "local-exec" {
  command = "${path.module}/docker_setup_local.sh"
}
provisioner "local-exec" {
  when    = "destroy"
  command = "${path.module}/docker_destroy_local.sh"
}
}
