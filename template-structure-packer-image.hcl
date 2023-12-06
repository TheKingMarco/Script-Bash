build {
 sources = ["sources.azure-arm.azurevm","sources.docker.docker-img"]
}
provisioner "shell" {
 scripts = ["hardening-config.sh"]
 }
provisioner "file" {
 source = "scripts/installers"
 destination = "/tmp/scripts"
 }