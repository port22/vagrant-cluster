#!/bin/bash

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum -y install docker-ce && sudo systemctl enable docker --now

if [[ $HOSTNAME = 'pcs1' ]]; then
  docker swarm init --advertise-addr 11.11.11.11
  docker run -d --rm --name join-token -v /vagrant/join-token:/token -p 80:8080 msoap/shell2http / \
    "echo $(docker swarm join-token manager -q)"
else
  docker swarm join --token $(curl -sf 11.11.11.11) 11.11.11.11:2377
fi
