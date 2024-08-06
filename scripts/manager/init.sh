#!/bin/bash

# Docker 설치 및 설정
sudo apt-get update
sudo apt-get install -y docker.io
sudo usermod -aG docker ubuntu
sudo systemctl enable docker
sudo systemctl start docker

# 매니저 노드 IP 주소 얻기
MANAGER_IP=$(hostname -I | awk '{print $1}')
echo "Manager IP: $MANAGER_IP"

# Docker Swarm 초기화
echo "Initializing Docker Swarm..."
sudo docker swarm init --advertise-addr $MANAGER_IP

# 워커 토큰 얻기
WORKER_TOKEN=$(sudo docker swarm join-token -q worker)
echo "Worker Token: $WORKER_TOKEN"

# 결과 출력
echo "Swarm initialization complete."
echo "Use the following command to join a worker node:"
echo "docker swarm join --token $WORKER_TOKEN $MANAGER_IP:2377"
