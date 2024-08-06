
[manager]
ubuntu@manager:~$ sudo apt-get update
sudo apt-get install -y docker.io
sudo usermod -aG docker ubuntu
sudo systemctl enable docker
sudo systemctl start docker

ubuntu@manager:~$ MANAGER_IP=$(hostname -I | awk '{print $1}')
ubuntu@manager:~$ echo $MANAGER_IP
192.168.64.4
ubuntu@manager:~$ sudo docker swarm init --advertise-addr $MANAGER_IP

Swarm initialized: current node (2wcxujq5u2he4w0qosefof2sv) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-40bhaejisc8l5pldff0azps8vndhdcw672pyj5cboumw8g7yvz-22x2tehe1itv8mmwzb56jx4gk 192.168.64.4:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

ubuntu@manager:~$ WORKER_TOKEN=$(sudo docker swarm join-token -q worker)

ubuntu@manager:~$ echo $WORKER_TOKEN
SWMTKN-1-40bhaejisc8l5pldff0azps8vndhdcw672pyj5cboumw8g7yvz-22x2tehe1itv8mmwzb56jx4gk



[worker] 
ubuntu@worker<n>:~$ WORKER_TOKEN=SWMTKN-1-40bhaejisc8l5pldff0azps8vndhdcw672pyj5cboumw8g7yvz-22x2tehe1itv8mmwzb56jx4gk

ubuntu@worker<n>:~$ WORKER_TOKEN=SWMTKN-1-40bhaejisc8l5pldff0azps8vndhdcw672pyj5cboumw8g7yvz-22x2tehe1itv8mmwzb56jx4gk
ubuntu@worker<n>:~$ MANAGER_IP=192.168.64.4

ubuntu@worker<n>:~$ sudo docker swarm join --token $WORKER_TOKEN $MANAGER_IP:2377
This node joined a swarm as a worker.


[manager]
ubuntu@manager:~$ sudo docker node ls
wjID                            HOSTNAME   STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
q2qvw9oguhg6ckyay5dfx1tnh     gateway    Ready     Active                          24.0.7
2wcxujq5u2he4w0qosefof2sv *   manager    Ready     Active         Leader           24.0.7
j5mhomrxkezybtezlikebe4gj     worker1    Ready     Active                          24.0.7
h4l3xzfo4n24ngliqxoh8ug0p     worker2    Ready     Active                          24.0.7
vul9gssu5tqkufwc6eo8c6rpd     worker3    Ready     Active                          24.0.7

ubuntu@manager:~$ sudo docker node update --label-add service=gateway gateway \
sudo docker node update --label-add service=party worker1 \
sudo docker node update --label-add service=party worker2 \
sudo docker node update --label-add service=party worker3


ubuntu@manager:~$ sudo docker node ls --filter node.label=service=gateway
ID                            HOSTNAME   STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
q2qvw9oguhg6ckyay5dfx1tnh     gateway    Ready     Active                          24.0.7

ubuntu@manager:~$ sudo docker node ls --filter node.label=service=party
ID                            HOSTNAME   STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
j5mhomrxkezybtezlikebe4gj     worker1    Ready     Active                          24.0.7
h4l3xzfo4n24ngliqxoh8ug0p     worker2    Ready     Active                          24.0.7
vul9gssu5tqkufwc6eo8c6rpd     worker3    Ready     Active                          24.0.7


ubuntu@manager:~$ sudo docker network create --driver overlay swarm-network
uczv2vc1n2988jabu1sg8ezbb
```
오버레이 네트워크란?
    오버레이 네트워크는 여러 Docker 데몬 호스트 간에 분산 네트워크를 생성하는 네트워크 드라이버입니다. 이 네트워크는 호스트별 네트워크 위에 위치하여, 컨테이너가 서로 다른 호스트에 있더라도 안전하게 통신할 수 있도록 합니다.

오버레이 네트워크의 필요성
    다중 호스트 통신: 오버레이 네트워크는 여러 호스트에 걸쳐 있는 컨테이너들 간의 통신을 가능하게 합니다. 이는 특히 Docker Swarm과 같은 분산 시스템에서 중요합니다.
    서비스 디스커버리: Docker Swarm은 오버레이 네트워크를 통해 서비스 디스커버리를 자동으로 처리합니다. 이는 서비스 이름을 사용하여 컨테이너 간의 통신을 간단하게 만듭니다.
    보안: 오버레이 네트워크는 암호화를 통해 데이터 전송의 보안을 강화할 수 있습니다.
    유연성: 컨테이너가 여러 네트워크에 연결될 수 있으며, 네트워크 간의 통신을 쉽게 설정할 수 있습니다.
```



(서비스 이미지 배포 이후)
ubuntu@manager:~$ docker login (이미지가 배포된 도커)

ubuntu@manager:~$ sudo docker service ls
ID             NAME      MODE         REPLICAS   IMAGE                PORTS
se87rmnq1wse   gateway   replicated   0/1        ooeunoo/gateway:v1   *:8080->8080/tcp

ubuntu@manager:~$ sudo docker service rm gateway
gateway

ubuntu@manager:~$ sudo docker service ls
ID        NAME      MODE      REPLICAS   IMAGE     PORTS

ubuntu@manager:~$ sudo docker service create   --name gateway   --network swarm-network   --replicas 1   -p 8080:8080   -e PARTY_NODES="http://party:8081"   --constraint 'node.labels.service == gateway'   ooeunoo/gateway:v1
ac31taup6kkg43224t2hurwl9
overall progress: 1 out of 1 tasks 
1/1: running   [==================================================>] 
verify: Service converged 


ubuntu@manager:~$ sudo docker service create   --name party   --network swarm-network   --replicas 3   -e NODE_NUMBER="{{.Task.Slot}}"   --constraint 'node.labels.service == party'   ooeunoo/party:v1
72kaw4lml958ge4at4zidorfi
overall progress: 3 out of 3 tasks 
1/3: running   [==================================================>] 
2/3: running   [==================================================>] 
3/3: running   [==================================================>] 
verify: Service converged 


ubuntu@manager:~$ sudo docker service ls
ID             NAME      MODE         REPLICAS   IMAGE                PORTS
ac31taup6kkg   gateway   replicated   1/1        ooeunoo/gateway:v1   *:8080->8080/tcp
72kaw4lml958   party     replicated   3/3        ooeunoo/party:v1     
ubuntu@manager:~$ sudo docker service ps gateway
ID             NAME        IMAGE                NODE      DESIRED STATE   CURRENT STATE           ERROR     PORTS
j568aikmrb2z   gateway.1   ooeunoo/gateway:v1   gateway   Running         Running 3 minutes ago   
ubuntu@manager:~$ sudo docker service ps party
ID             NAME      IMAGE              NODE      DESIRED STATE   CURRENT STATE                ERROR     PORTS
qkpfs9sp8swt   party.1   ooeunoo/party:v1   worker1   Running         Running 58 seconds ago                 
l1dxml5lvdv5   party.2   ooeunoo/party:v1   worker3   Running         Running 56 seconds ago                 
rt3g0mnfk4et   party.3   ooeunoo/party:v1   worker2   Running         Running about a minute ago             
ubuntu@manager:~$ sudo docker service logs gateway
ubuntu@manager:~$ sudo docker service logs party