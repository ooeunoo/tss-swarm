# Docker Swarm Cluster on AWS EC2

이 프로젝트는 AWS EC2 인스턴스를 사용하여 Docker Swarm 클러스터를 구성하고, 매니저 노드와 워커 노드를 설정하는 방법을 설명합니다.

## 프로젝트 구성

- AWS EC2 인스턴스 4개 (1개의 매니저 노드, 3개의 워커 노드)
- Docker Swarm 클러스터
- Golang 기반의 Gateway 및 Party 서비스

## 요구 사항

- AWS 계정
- AWS Management Console 접근 권한
- SSH 키 페어
- Docker 설치 지식

## 설정 단계

### 1. AWS EC2 인스턴스 생성

AWS Management Console을 사용하여 4개의 EC2 인스턴스를 생성합니다:

1. **EC2 인스턴스 생성**:
   - 인스턴스 타입: t3.nano
   - 운영 체제: Amazon Linux 2
   - 보안 그룹 설정: SSH(22), Docker Swarm(2377, 7946, 4789) 포트 개방
   - 각 인스턴스에 태그 추가: `manager`, `worker1`, `worker2`, `worker3`

2. **보안 그룹 설정**:
   - **인바운드 규칙**:
     - SSH: 포트 22, 소스: My IP
     - Docker Swarm 관리: 포트 2377, 소스: 0.0.0.0/0
     - Docker Swarm 노드 간 통신: 포트 7946 (TCP/UDP), 소스: 0.0.0.0/0
     - Docker Swarm 오버레이 네트워크: 포트 4789 (UDP), 소스: 0.0.0.0/0
   - **아웃바운드 규칙**:
     - 기본적으로 모든 트래픽 허용

### 2. 매니저 노드 설정

매니저 노드로 사용할 EC2 인스턴스에 SSH로 접속한 후 다음 스크립트를 실행합니다:

```bash
#!/bin/bash

# Docker 설치
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

# Docker Swarm 초기화
MANAGER_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sudo docker swarm init --advertise-addr $MANAGER_IP
```

### 3. 워커 노드 설정

매니저 노드에서 워커 노드를 추가하기 위한 토큰을 획득합니다:

```bash
WORKER_TOKEN=$(sudo docker swarm join-token -q worker)
```

각 워커 노드에 SSH로 접속하여 다음 스크립트를 실행합니다:

```bash
#!/bin/bash

# Docker 설치
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

# Docker Swarm 조인
sudo docker swarm join --token $WORKER_TOKEN $MANAGER_IP:2377
```

### 4. 서비스 배포

매니저 노드에서 다음 명령어를 실행하여 서비스를 배포합니다:

```bash
# Gateway 서비스 배포
sudo docker service create \
    --name gateway \
    --replicas 1 \
    -p 8080:8080 \
    -e PARTY_NODES="http://party:8081,http://party:8081,http://party:8081,http://party:8081" \
    --constraint node.labels.service==gateway \
    your-registry/gateway:v1

# Party 서비스 배포
sudo docker service create \
    --name party \
    --replicas 3 \
    -e NODE_NUMBER="{{.Task.Slot}}" \
    --constraint node.labels.service==party \
    your-registry/party:v1
```

### 5. 서비스 확인

매니저 노드에서 서비스 상태를 확인합니다:

```bash
sudo docker service ls
sudo docker service ps gateway
sudo docker service ps party
```

## Dockerfile

### Gateway Dockerfile

```dockerfile
FROM golang:1.16
WORKDIR /app
COPY gateway.go .
RUN go build -o gateway
CMD ["./gateway"]
```

### Party Dockerfile

```dockerfile
FROM golang:1.16
WORKDIR /app
COPY party.go .
RUN go build -o party
CMD ["./party"]
```

## 이미지 빌드 및 푸시

```bash
docker build -t your-registry/gateway:v1 -f Dockerfile.gateway .
docker build -t your-registry/party:v1 -f Dockerfile.party .
docker push your-registry/gateway:v1
docker push your-registry/party:v1
```

## 참고 사항

- 실제 환경에서는 보안 설정을 강화해야 합니다.
- 네트워크 설정 및 로드 밸런싱 고려가 필요할 수 있습니다.
- 서비스 스케일링 및 업데이트 전략을 계획해야 합니다.
- 모니터링 및 로깅 솔루션 구현을 고려하세요.

이 프로젝트를 통해 AWS EC2 인스턴스를 사용하여 Docker Swarm 클러스터를 구성하고, 분산 시스템을 구현하는 기본적인 방법을 학습할 수 있습니다.
```

이 README 파일은 AWS Management Console을 사용하여 EC2 인스턴스를 생성하고, 보안 그룹 설정, Docker Swarm 클러스터 구성, 서비스 배포 및 확인 방법을 포함하고 있습니다. 이를 통해 프로젝트를 쉽게 설정하고 관리할 수 있습니다.

Citations:
[1] https://bommbom.tistory.com/entry/EC2-%EB%B3%B4%EC%95%88-%EA%B7%B8%EB%A3%B9-%EC%9D%B8%EB%B0%94%EC%9A%B4%EB%93%9C-%EC%95%84%EC%9B%83%EB%B0%94%EC%9A%B4%EB%93%9C-3%EB%8B%A8%EA%B3%84-%EC%84%A4%EC%A0%95-%EB%B0%A9%EB%B2%95
[2] https://dbjh.tistory.com/65
[3] https://brunch.co.kr/%40jscode/26
[4] https://zamezzz.tistory.com/301
[5] https://velog.io/%40ironkey/AWS-%EB%B3%B4%EC%95%88-%EA%B7%B8%EB%A3%B9-%EC%9D%B8%EB%B0%94%EC%9A%B4%EB%93%9C-%EA%B7%9C%EC%B9%99-%EC%84%A4%EC%A0%95%ED%95%98%EA%B8%B0