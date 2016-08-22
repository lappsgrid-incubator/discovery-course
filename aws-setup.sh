#!/bin/bash
apt-get update
apt-get install -y emacs24-nox apt-transport-https ca-certificates nfs-common make git unzip
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y linux-image-extra-$(uname -r) docker-engine
git clone https://github.com/lappsgrid-incubator/discovery-course.git
cd discovery-course && cp connect clone build lappsgrid gitpull run /usr/local/bin
mkdir -p /var/local/corpora
cd /var/local/corpora 
wget http://www.cs.brandeis.edu/~marc/lapps/discovery/corpora/kidnap1.tgz
wget http://www.cs.brandeis.edu/~marc/lapps/discovery/corpora/kidnap1-s.tgz
wget http://www.cs.brandeis.edu/~marc/lapps/discovery/corpora/kidnap2.tgz
wget http://www.cs.brandeis.edu/~marc/lapps/discovery/corpora/kidnap2-s.tgz
tar zxf kidnap1.tgz
tar zxf kidnap1-s.tgz
tar zxf kidnap2.tgz
tar zxf kidnap2-s.tgz
docker run --name ecs-agent \
--detach=true \
--restart=on-failure:10 \
--volume=/var/run/docker.sock:/var/run/docker.sock \
--volume=/var/log/ecs/:/log \
--volume=/var/lib/ecs/data:/data \
--volume=/sys/fs/cgroup:/sys/fs/cgroup:ro \
--volume=/var/run/docker/execdriver/native:/var/lib/docker/execdriver/native:ro \
--publish=127.0.0.1:51678:51678 \
--env=ECS_LOGFILE=/log/ecs-agent.log \
--env=ECS_LOGLEVEL=info \
--env=ECS_DATADIR=/data \
--env=ECS_CLUSTER=lappsgrid-discovery-cluster \
amazon/amazon-ecs-agent:latest
