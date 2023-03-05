docker run -d --name master-node \
-v /data/defichain:/home/defichain/data -p 8555:8555 \
--restart on-failure:3 --security-opt="no-new-privileges=true" \
shibug/defichain:3.2.6

#Get Block count
dke master-node /home/defichain/.defi/defi-cli -datadir=/home/defichain/data getblockcount

#Get Peer count
dke master-node /home/defichain/.defi/defi-cli -datadir=/home/defichain/data getpeercount

#Get Information
dke master-node /home/defichain/.defi/defi-cli -datadir=/home/defichain/data -getinfo

#Send DFI
dke master-node /home/defichain/.defi/defi-cli -datadir=/home/defichain/data sendtoaddress <address> <amount>

#Update Masternode
dke master-node /home/defichain/.defi/defi-cli -datadir=/home/defichain/data updatemasternode a774893c3df67805ac39a16915ab514c35a9bf9ee9b4886f51cbc1c7fac7a039 {"rewardAddress":"df1qlj9sz7zxhv672f57gusu2ypsqcd3vnaxej8u0f"}