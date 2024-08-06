#!/bin/bash

# 서비스 목록
SERVICES=("gateway" "party")

# 실시간 로그 출력
echo "Starting real-time log monitoring..."

for SERVICE in "${SERVICES[@]}"
do
    echo "Tailing logs for $SERVICE..."
    sudo docker service logs -f $SERVICE &
done

# 모든 백그라운드 작업이 완료될 때까지 대기
wait
