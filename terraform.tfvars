# ----- CLOUDFLARE PROVIDER ----- #

// If using a Cloudflare-Provider make sure to store API-Token and Account-ID in "secret.tfvars" 
//
// cloudflare_api_token        = <API-Token>
// cloudflare_account_id       = <Account-ID>
//
// Apply the settings with [terraform apply -var-file="secret.tfvars"]

cloudflare_tunnel01_name    = "zt-demo-tunnel-linux"
cloudflare_zone             = "mike-demo.uk"
cloudflare_email            = "mmajunke@cloudflare.com"

# ---- GCP PROVIDER ---- #
service_account_path        = "/Users/mmajunke/.config/gcloud/application_default_credentials.json"
project                     = "globalse-198312"
region                      = "europe-west3"
zone                        = "europe-west3-b"
prefix                      = "mmajunke"
name                        = "zt-demo"
owner                       = "mmajunke"
scheduler                   = "emea"
machine_type                = "e2-small"
disk_type                   = "pd-balanced"
disk_size                   = 50
image                       = "ubuntu-2204-jammy-v20220810"
enable_monitoring           = false
public_key_path             = "/Users/mmajunke/.ssh/id_rsa.pub"
ssh_user                    = "mmajunke"
