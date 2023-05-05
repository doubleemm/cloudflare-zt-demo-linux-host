#!/bin/bash
set -e

### Installing cloudflared
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && 
sudo dpkg -i cloudflared.deb
sudo cloudflared service install ${tunnel_token} 

### Installing Docker ###
apt update
apt install -y docker.io docker-compose
usermod -aG docker ${owner}

### Set-up httpbin container in separate network ###
sudo docker network create --driver bridge httpbin-net
sudo docker run --name httpbin01  --network httpbin-net -p80:80  -d kennethreitz/httpbin

### Set-up juiceshop container in separate network ###
sudo docker run --name juiceshop01  -p3000:3000  -d bkimminich/juice-shop

### Set-up Owncloud-Container ### 
#mkdir /home/mmajunke/docker-owncloud
#wget -O /home/mmajunke/docker-owncloud/docker-compose.yml https://raw.githubusercontent.com/owncloud/docs-server/master/modules/admin_manual/examples/installation/docker/docker-compose.yml
#cat <<"EOF" | sudo tee /home/mmajunke/docker-owncloud/.env
#OWNCLOUD_VERSION=latest
#OWNCLOUD_DOMAIN=172.17.0.2:8080
#OWNCLOUD_TRUSTED_DOMAINS=172.17.0.2
#ADMIN_USERNAME=admin
#ADMIN_PASSWORD=admin
#HTTP_PORT=8080
#EOF
#sudo docker-compose -f /home/mmajunke/docker-owncloud/docker-compose.yml up -d

### Setup Apache Guacamole
sudo docker pull guacamole/guacd
sudo docker pull guacamole/guacamole
sudo docker run --name guacamoledb -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=guacdb -d mysql/mysql-server
sudo docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql | tee initdb.sql
sudo docker cp /initdb.sql guacamoledb:initdb.sql
sudo sleep 90
sudo docker exec -i guacamoledb mysql -u root -ppassword -e "use guacdb; source initdb.sql; create user guacadmin@'%' identified by 'password'; grant SELECT,UPDATE,INSERT,DELETE on guacdb.* to guacadmin@'%'; flush privileges;"
sudo docker run --name guacamole-server -d guacamole/guacd
sudo docker run --name guacamole-client --link guacamole-server:guacd --link guacamoledb:mysql -e MYSQL_DATABASE=guacdb -e MYSQL_USER=guacadmin -e MYSQL_PASSWORD=password -d -p 8081:8080 guacamole/guacamole
