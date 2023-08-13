#!/bin/bash

sudo apt-get update;
rm -r /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

echo ""
echo ""
echo "https://www.youtube.com/@IR_TECH"
echo "PLEASE WAIT INSTALLING DOCKER...."                                                                                                                         
echo ""
echo ""

apt install curl -y
sudo curl -sS https://get.docker.com/ | sh
sudo systemctl start docker
sudo systemctl enable docker

wget https://mirdehghan.ir/dl/Docker-image-Mikrotik-7.7-L6.7z
sudo apt-get install p7zip-full
7z e Docker-image-Mikrotik-7.7-L6.7z
docker load --input mikrotik7.7_docker_livekadeh.com
docker run --cap-add=NET_ADMIN --device=/dev/net/tun -d --name livekadeh_com_mikrotik7_7 -p 8291:8291  -ti livekadeh_com_mikrotik7_7
docker attach livekadeh_com_mikrotik7_7

