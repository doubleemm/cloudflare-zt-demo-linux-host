# Output the tunnel token and secret

output "tunnel_token01" {
  value = cloudflare_argo_tunnel.zt-demo-srv-linux.tunnel_token
}

output "tunnel_secret" {
  value = random_id.tunnel_secret
}
