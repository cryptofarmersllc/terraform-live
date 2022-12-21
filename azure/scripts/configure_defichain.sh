docker run -d --name master-node \
-v /data/defichain:/home/defichain/data -p 8555:8555 \
--restart on-failure:3 --security-opt="no-new-privileges=true" \
shibug/defichain:3.1.1