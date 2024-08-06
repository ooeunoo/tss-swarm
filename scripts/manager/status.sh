#!/bin/bash

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 서비스 목록
SERVICES=("gateway" "party")

# 현재 시간 출력
echo -e "${YELLOW}Monitoring started at $(date)${NC}\n"

# 노드 상태 확인
echo -e "${GREEN}Checking Node Status:${NC}"
sudo docker node ls
echo

# 서비스 상태 확인
echo -e "${GREEN}Checking Service Status:${NC}"
sudo docker service ls
echo

# 각 서비스의 상세 상태 및 로그 확인
for SERVICE in "${SERVICES[@]}"
do
    echo -e "${GREEN}Detailed status for $SERVICE:${NC}"
    sudo docker service ps $SERVICE
    echo

    echo -e "${GREEN}Recent logs for $SERVICE:${NC}"
    sudo docker service logs --tail 10 $SERVICE
    echo
done

# 시스템 리소스 사용량 확인
echo -e "${GREEN}System Resource Usage:${NC}"
echo -e "${YELLOW}CPU Usage:${NC}"
top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}'

echo -e "${YELLOW}Memory Usage:${NC}"
free -m | awk 'NR==2{printf "%.2f%%\n", $3*100/$2 }'

echo -e "${YELLOW}Disk Usage:${NC}"
df -h | awk '$NF=="/"{printf "%s\n", $5}'

# 네트워크 상태 확인
echo -e "\n${GREEN}Network Status:${NC}"
netstat -tuln

echo -e "\n${YELLOW}Monitoring completed at $(date)${NC}"
