##################################################################################################################
# Create a local syncthing
##################################################################################################################
module "syncthing_local" {
  source = "../../../../modules/syncthing"
  gui = true
  conf_dir = "${var.syncthing_conf_dir}"
  data_dir = "${var.syncthing_data_dir}"
}
