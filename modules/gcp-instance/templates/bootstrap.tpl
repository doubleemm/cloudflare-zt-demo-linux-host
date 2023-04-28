#!/bin/bash
set -e

### Installing cloudflared
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && 
sudo dpkg -i cloudflared.deb
sudo cloudflared service install ${tunnel_token} 

### Installing Docker ###
apt update
apt install -y docker.io docker-compose
usermod -aG docker mmajunke

### Set-up httpbin container in separate network ###
sudo docker network create --driver bridge httpbin-net
sudo docker run --name httpbin01  --network httpbin-net -p80:80  -d kennethreitz/httpbin

### Set-up juiceshop container in separate network ###
sudo docker run --name juiceshop01  -p3000:3000  -d bkimminich/juice-shop

### Set-up Owncloud-Container ### 
mkdir /home/mmajunke/docker-owncloud
wget -O /home/mmajunke/docker-owncloud/docker-compose.yml https://raw.githubusercontent.com/owncloud/docs-server/master/modules/admin_manual/examples/installation/docker/docker-compose.yml
cat <<"EOF" | sudo tee /home/mmajunke/docker-owncloud/.env
OWNCLOUD_VERSION=latest
OWNCLOUD_DOMAIN=172.17.0.2:8080
OWNCLOUD_TRUSTED_DOMAINS=172.17.0.2
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin
HTTP_PORT=8080
EOF
sudo docker-compose -f /home/mmajunke/docker-owncloud/docker-compose.yml up -d

