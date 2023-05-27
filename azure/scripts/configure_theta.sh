docker run -d --name guardian-node \
-v /data/guardian:/home/theta/.theta \
--restart on-failure:3 --security-opt="no-new-privileges=true" \
shibug/theta-guardian-node:4.0.0 \
start --snapshot=/home/theta/.theta/snapshot --password=''

