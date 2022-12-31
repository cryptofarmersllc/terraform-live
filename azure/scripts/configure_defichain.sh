docker run -d --name master-node \
-v /data/defichain:/home/defichain/data -p 8555:8555 \
--restart on-failure:3 --security-opt="no-new-privileges=true" \
shibug/defichain:3.1.1

#Get Block count
dke master-node /home/defichain/.defi/defi-cli -datadir=/home/defichain/data getblockcount

#Get Peer count
dke master-node /home/defichain/.defi/defi-cli -datadir=/home/defichain/data getpeercount

#Get Information
dke master-node /home/defichain/.defi/defi-cli -datadir=/home/defichain/data -getinfo

#Send DFI
dke master-node /home/defichain/.defi/defi-cli -datadir=/home/defichain/data sendtoaddress <address> <amount>