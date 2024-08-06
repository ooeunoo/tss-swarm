#!/bin/bash

# 사용자로부터 매니저 IP와 워커 토큰 입력 받기
read -p "Enter the Manager IP: " MANAGER_IP
read -p "Enter the Worker Token: " WORKER_TOKEN

# 입력 값 확인
echo "Manager IP: $MANAGER_IP"
echo "Worker Token: $WORKER_TOKEN"

# Docker 설치 및 설정 (이미 설치되어 있지 않은 경우)
if ! command -v docker &> /dev/null
then
    echo "Docker not found. Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo usermod -aG docker ubuntu
    sudo systemctl enable docker
    sudo systemctl start docker
else
    echo "Docker is already installed."
fi

# Docker Swarm 조인
echo "Joining Docker Swarm..."
sudo docker swarm join --token $WORKER_TOKEN $MANAGER_IP:2377

# 결과 확인
if [ $? -eq 0 ]; then
    echo "Successfully joined the swarm."
else
    echo "Failed to join the swarm. Please check your inputs and try again."
fi
