#!/bin/bash

# JSON 파일 경로
CONFIG_FILE="config.json"

# JSON 파일 읽기 및 상수화
USERNAME=$(jq -r '.username' $CONFIG_FILE)
GATEWAY_IMAGE=$(jq -r '.gateway.image' $CONFIG_FILE)
GATEWAY_VERSION=$(jq -r '.gateway.version' $CONFIG_FILE)
PARTY_IMAGE=$(jq -r '.party.image' $CONFIG_FILE)
PARTY_VERSION=$(jq -r '.party.version' $CONFIG_FILE)

# Docker Hub 로그인
echo "Logging in to Docker Hub..."
docker login

# Gateway 서비스 업데이트
echo "Updating Gateway service..."
sudo docker service update \
  --image $USERNAME/$GATEWAY_IMAGE:$GATEWAY_VERSION \
  gateway

# Party 서비스 업데이트
echo "Updating Party service..."
sudo docker service update \
  --image $USERNAME/$PARTY_IMAGE:$PARTY_VERSION \
  party

# 업데이트된 서비스 확인
echo "Verifying updated services..."
sudo docker service ls

echo "Redeployment completed. Checking service status..."
sudo docker service ps gateway
sudo docker service ps party

echo "Redeployment process completed successfully."
