#!/bin/bash

# 사용자 이름을 상수로 정의
USERNAME="ooeunoo"

# Gateway 서비스 빌드 및 푸시
cd gateway
docker build -t $USERNAME/gateway:v1 .
docker push $USERNAME/gateway:v1
cd ..

# Party 서비스 빌드 및 푸시
cd party
docker build -t $USERNAME/party:v1 .
docker push $USERNAME/party:v1
cd ..

echo "모든 이미지가 빌드되고 푸시되었습니다."
