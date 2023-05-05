provider "google" {
  credentials = file(var.service_account_path)
  project     = var.project
  region      = var.region

}

resource "time_static" "timestamp" {}

resource "google_compute_instance" "vm" {
  count = 1
  name = "${var.prefix}-${time_static.timestamp.unix}-${count.index}"
  machine_type = var.machine_type
  zone = var.zone
  labels = {
    "owner" =  var.owner
    "scheduler" = var.scheduler
    "service" = var.name
  }
  boot_disk {
    auto_delete = true
    initialize_params {
      size = var.disk_size
      image = var.image
    }  
  }
  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }

metadata = {
    ssh-keys = "${var.ssh_user}:${file("${var.public_key_path}")}"
  }

#metadata_startup_script = file("${path.module}/templates/bootstrap.tpl")
metadata_startup_script = templatefile("${path.module}/templates/bootstrap.tpl",{
  tunnel_token = var.cf_tunnel_token01
  owner = var.owner
})

}
