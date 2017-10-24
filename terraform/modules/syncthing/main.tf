# Configure the Docker provider
provider "docker" {
  host = "tcp://127.0.0.1:2376/"
}


data "docker_registry_image" "syncthing" {
  name = "syncthing/syncthing:v0.14.39"
}

resource "docker_image" "syncthing" {
  name          = "${data.docker_registry_image.syncthing.name}"
  pull_triggers = ["${data.docker_registry_image.syncthing.sha256_digest}"]
}

# Create the container
resource "docker_container" "syncthing" {
  depends_on = ["docker_image.syncthing"]

  image = "${data.docker_registry_image.syncthing.name}"
  name  = "gj2s-syncthing"
  restart = "always"
  must_run = true
  ports = {
    internal = 8384
    external = 8385
  }
  ports = {
    internal = 21000
    external = 21000
  }
  volumes = {
    host_path = "${var.data_dir}"
    container_path = "/var/syncthing/Sync"
  }
  volumes = {
    host_path = "${var.conf_dir}"
    container_path = "/var/syncthing/config"
  }
}

#Process the config.xml file that was generated
data "external" "syncthing_data" {
#  depends_on = ["docker_container.syncthing"]
  program = ["bash", "${path.module}/process_config.sh"]

  query = {
    # arbitrary map from strings to strings, passed
    # to the external program as the data query.
    conf = "${var.conf_dir}/config.xml"
    gui = "${var.gui}"
    container_id = "${docker_container.syncthing.id}"
  }
}
