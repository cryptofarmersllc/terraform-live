docker run -d --name master-node \
-v /data/defichain:/home/defichain/data -p 8555:8555 \
--restart on-failure:3 --security-opt="no-new-privileges=true" \
shibug/defichain:3.2.8

#Get Block count
dke master-node /home/defichain/.defi/defi-cli -datadir=/home/defichain/data getblockcount

#Get Peer count
dke master-node /home/defichain/.defi/defi-cli -datadir=/home/defichain/data getpeercount

#Get Information
dke master-node /home/defichain/.defi/defi-cli -datadir=/home/defichain/data -getinfo

#Send DFI
dke master-node /home/defichain/.defi/defi-cli -datadir=/home/defichain/data sendtoaddress <address> <amount>

#Create Masternode
dke master-node /home/defichain/.defi/defi-cli -datadir=/home/defichain/data createmasternode <owner_address> <operator_addres>

#Update Masternode
dke master-node /home/defichain/.defi/defi-cli -datadir=/home/defichain/data updatemasternode a774893c3df67805ac39a16915ab514c35a9bf9ee9b4886f51cbc1c7fac7a039 {"rewardAddress":"<reward_address>"}