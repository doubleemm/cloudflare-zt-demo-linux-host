terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Generate a random secret for the tunnel
resource "random_id" "tunnel_secret" {
  byte_length  = 32
}

### Create CF Tunnel
resource "cloudflare_argo_tunnel" "zt-demo-srv-linux" {
  account_id = var.cloudflare_account_id
  name       = var.cloudflare_tunnel01_name
  secret     = random_id.tunnel_secret.b64_std
}

### Create DNS 
resource "cloudflare_record" "zt-demo-ssh" {
  zone_id = var.cloudflare_zone_id
  name    = "ssh"
  value   = cloudflare_argo_tunnel.zt-demo-srv-linux.cname
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "zt-demo-shop" {
  zone_id = var.cloudflare_zone_id
  name    = "shop"
  value   = cloudflare_argo_tunnel.zt-demo-srv-linux.cname
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "zt-demo-owncloud" {
  zone_id = var.cloudflare_zone_id
  name    = "owncloud"
  value   = cloudflare_argo_tunnel.zt-demo-srv-linux.cname
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "zt-demo-guacamole" {
  zone_id = var.cloudflare_zone_id
  name    = "rdpweb"
  value   = cloudflare_argo_tunnel.zt-demo-srv-linux.cname
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "httpbin" {
  zone_id = var.cloudflare_zone_id
  name    = "httpbin"
  value   = var.server_ip
  type    = "A"
  proxied = true
}

### CREATE ACCESS APPLICATION

resource "cloudflare_access_application" "zt-demo-ssh-app" {
  zone_id          = var.cloudflare_zone_id
  name             = "Access protection for ssh.${var.cloudflare_zone}"
  domain           = "ssh.${var.cloudflare_zone}"
  session_duration = "1h"
}

resource "cloudflare_access_application" "zt-demo-guacamole-app" {
  zone_id          = var.cloudflare_zone_id
  name             = "Access protection for ${cloudflare_record.zt-demo-guacamole.name}.${var.cloudflare_zone}"
  domain           = "${cloudflare_record.zt-demo-guacamole.name}.${var.cloudflare_zone}"
  session_duration = "1h"
}

### CREATE ACCESS-POLICY FOR SSH ACCESS

resource "cloudflare_access_policy" "zt-demo-rdp-policy" {
  application_id = cloudflare_access_application.zt-demo-ssh-app.id
  zone_id        = var.cloudflare_zone_id
  name           = "Example Policy for ssh.${var.cloudflare_zone}"
  precedence     = "1"
  decision       = "allow"
 
  include {
    email = ["${var.cloudflare_email}"]
  }
}

resource "cloudflare_access_policy" "zt-demo-webrdp-policy" {
  application_id = cloudflare_access_application.zt-demo-guacamole-app.id
  zone_id        = var.cloudflare_zone_id
  name           = "Example Policy for ${cloudflare_record.zt-demo-guacamole.name}.${var.cloudflare_zone}"
  precedence     = "1"
  decision       = "allow"
 
  include {
    email = ["${var.cloudflare_email}"]
  }
}

resource "cloudflare_tunnel_config" "zt-demo-srv-linux-config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_argo_tunnel.zt-demo-srv-linux.id

  config {
    warp_routing {
      enabled = true
    }
    
    ingress_rule {
      hostname = "${cloudflare_record.zt-demo-ssh.name}.${var.cloudflare_zone}"
      service  = "ssh://localhost:22"
    }

    ingress_rule {
      hostname = "${cloudflare_record.zt-demo-shop.name}.${var.cloudflare_zone}"
      service  = "http://localhost:3000"
    }

    ingress_rule {
      hostname = "${cloudflare_record.zt-demo-owncloud.name}.${var.cloudflare_zone}"
      service  = "https://localhost:8080"
    }

       ingress_rule {
      hostname = "${cloudflare_record.zt-demo-guacamole.name}.${var.cloudflare_zone}"
      service  = "https://localhost:8081"
    }

    ingress_rule {
      service  = "http_status:404"
    }
  }
}


### GATEWAY POLICIES

