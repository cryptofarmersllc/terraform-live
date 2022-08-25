#Rsync beacon node database

------------------------------------------------------------
#Run your executor node
#Node 1
docker run -d --name executor-node \
  -v /data/ethereum/data:/root/.ethereum -v /data/ethereum/config:/root/config \
  -p 6060:6060 -p 8551:8551 -p 30303:30303/tcp -p 30303:30303/udp \
  --restart on-failure:3 --security-opt="no-new-privileges=true" \
  ethereum/client-go:v1.10.23 \
  --mainnet \
  --syncmode full \
  --authrpc.addr 0.0.0.0 \
  --authrpc.vhosts '*' \
  --authrpc.jwtsecret=/root/config/jwt.hex \
  --http \
  --http.api eth,net,engine,admin \
  --metrics \
  --metrics.addr 0.0.0.0


#Setup notification on beaconchain for the new node

------------------------------------