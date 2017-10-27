output "api" {
  value = "${data.external.syncthing_data.result["apikey"]}"
}
output "what" {
  value = "${data.external.syncthing_data.result["what"]}"
}
