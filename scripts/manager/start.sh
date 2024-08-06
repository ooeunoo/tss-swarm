#!/bin/bash

# JSON 파일 경로
CONFIG_FILE="config.json"

# JSON 파일 읽기 및 상수화
USERNAME=$(jq -r '.username' $CONFIG_FILE)
GATEWAY_IMAGE=$(jq -r '.gateway.image' $CONFIG_FILE)
GATEWAY_VERSION=$(jq -r '.gateway.version' $CONFIG_FILE)
GATEWAY_REPLICAS=$(jq -r '.gateway.replicas' $CONFIG_FILE)
GATEWAY_PORT=$(jq -r '.gateway.port' $CONFIG_FILE)
GATEWAY_ENV_PARTY_NODES=$(jq -r '.gateway.env.PARTY_NODES' $CONFIG_FILE)

PARTY_IMAGE=$(jq -r '.party.image' $CONFIG_FILE)
PARTY_VERSION=$(jq -r '.party.version' $CONFIG_FILE)
PARTY_REPLICAS=$(jq -r '.party.replicas' $CONFIG_FILE)
PARTY_ENV_NODE_NUMBER=$(jq -r '.party.env.NODE_NUMBER' $CONFIG_FILE)

# Docker Hub 로그인
echo "Logging in to Docker Hub..."
docker login

# 기존 서비스 제거
echo "Removing existing services..."
sudo docker service rm gateway party

# 서비스 목록 확인
echo "Checking current services..."
sudo docker service ls

# Gateway 서비스 배포
echo "Deploying Gateway service..."
sudo docker service create \
  --name gateway \
  --network swarm-network \
  --replicas $GATEWAY_REPLICAS \
  -p $GATEWAY_PORT:$GATEWAY_PORT \
  -e PARTY_NODES="$GATEWAY_ENV_PARTY_NODES" \
  --constraint 'node.labels.service == gateway' \
  $USERNAME/$GATEWAY_IMAGE:$GATEWAY_VERSION

# Party 서비스 배포
echo "Deploying Party service..."
sudo docker service create \
  --name party \
  --network swarm-network \
  --replicas $PARTY_REPLICAS \
  -e NODE_NUMBER="$PARTY_ENV_NODE_NUMBER" \
  --constraint 'node.labels.service == party' \
  $USERNAME/$PARTY_IMAGE:$PARTY_VERSION

# 배포된 서비스 확인
echo "Verifying deployed services..."
sudo docker service ls

echo "Deployment completed. Checking service status..."
sudo docker service ps gateway
sudo docker service ps party

echo "Deployment process completed successfully."
