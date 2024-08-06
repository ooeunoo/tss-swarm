#!/bin/bash

# 노드 상태 확인
echo "Checking node status..."
sudo docker node ls

# 노드에 라벨 추가
echo "Adding labels to nodes..."
sudo docker node update --label-add service=gateway gateway
sudo docker node update --label-add service=party worker1
sudo docker node update --label-add service=party worker2
sudo docker node update --label-add service=party worker3

# 라벨 적용 확인
echo "Verifying gateway label..."
sudo docker node ls --filter node.label=service=gateway

echo "Verifying party label..."
sudo docker node ls --filter node.label=service=party

# 오버레이 네트워크 생성
echo "Creating overlay network..."
NETWORK_ID=$(sudo docker network create --driver overlay swarm-network)

echo "Overlay network created with ID: $NETWORK_ID"

# 최종 상태 확인
echo "Final node status:"
sudo docker node ls

echo "Prebuild process completed successfully."
