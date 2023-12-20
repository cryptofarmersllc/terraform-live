docker run -d --name master-node \
-v /data/defichain:/home/defichain/data -p 8555:8555 \
--restart on-failure:3 --security-opt="no-new-privileges=true" \
shibug/defichain:4.0.6

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
dke master-node /home/defichain/.defi/defi-cli -datadir=/home/defichain/data updatemasternode <masternode_address> {"rewardAddress":"df1qlj9sz7zxhv672f57gusu2ypsqcd3vnaxej8u0f"}