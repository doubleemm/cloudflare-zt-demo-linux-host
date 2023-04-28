module "gcp-instance" {
  source = "./modules/gcp-instance"

  service_account_path        = var.service_account_path
  project                     = var.project
  region                      = var.region
  zone                        = var.zone
  prefix                      = var.prefix
  name                        = var.name
  owner                       = var.owner
  scheduler                   = var.scheduler
  machine_type                = var.machine_type
  disk_type                   = var.disk_type
  disk_size                   = var.disk_size
  image                       = var.image
  enable_monitoring           = var.enable_monitoring
  public_key_path             = var.public_key_path
  ssh_user                    = var.ssh_user
  cf_tunnel_token01           = module.cloudflare.tunnel_token01
}

module "cloudflare" {
  source="./modules/cloudflare"

  cloudflare_api_token      = var.cloudflare_api_token
  cloudflare_account_id     = var.cloudflare_account_id
  cloudflare_zone           = var.cloudflare_zone 
  cloudflare_zone_id        = var.cloudflare_zone_id
  cloudflare_email          = var.cloudflare_email
  cloudflare_tunnel01_name  = var.cloudflare_tunnel01_name
  server_ip                 = module.gcp-instance.server_ip
}

