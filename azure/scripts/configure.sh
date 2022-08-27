#Rsync beacon node database
#Copy private key to destination node
scp ~/.ssh/id_rsa ~/.ssh/id_rsa.pub ~/.ssh/config validator3.cryptofarmers.io:/home/groot/.ssh/
#verify ssh connection is established from destination to source node
ssh use2lvalidator001prod -p 1122
exit
#Rsync beacon node database from source to destination node while source beacon node is running
cd /data/ethereum/node1/beacon
mkdir beaconchaindata
cd beaconchaindata
rsync --progress -avzhe "ssh -p 1122" use2lvalidator002prod:/data/ethereum/node1/beacon/beaconchaindata/beaconchain.db .
#Rsync beacon node database from source to destination node while source beacon node is stopped
rsync --progress -avzhe "ssh -p 1122" use2lvalidator002prod:/data/ethereum/node1/beacon/beaconchaindata/beaconchain.db .
#Remove private keys from destination node
rm -fr  ~/.ssh/id_rsa ~/.ssh/id_rsa.pub ~/.ssh/config

------------------------------------------------------------
#Run your beacon node
#Node 1
docker run -d -v /data/ethereum/node1/beacon:/data -v /data/ethereum/node1/logs:/logs \
  -p 4000:4000 -p 8080:8080 -p 13000:13000 -p 12000:12000/udp \
  --name beacon-node-1 --restart on-failure:3 --security-opt="no-new-privileges=true" \
  gcr.io/prysmaticlabs/prysm/beacon-chain:v3.0.0 \
  --datadir=/data \
  --rpc-host=0.0.0.0 \
  --monitoring-host=0.0.0.0 \
  --http-web3provider=https://mainnet.infura.io/v3/e688007f8726451192c518e37fe0cdda \
  --fallback-web3provider=https://eth-mainnet.alchemyapi.io/v2/sCbtfxyKigCsKteX3M_pLT-KnboRLMcI \
  --log-file=/logs/beacon-node.log \
  --accept-terms-of-use \
  --p2p-max-peers 23 \
  --suggested-fee-recipient=0xa63Ce14Bc241812e3081A74b0b999b0D2bF0657F

#Node 2
docker run -d -v /data/ethereum/node2/beacon:/data -v /data/ethereum/node2/logs:/logs \
  -p 4002:4002 -p 8082:8082 -p 13002:13002 -p 12002:12002/udp \
  --name beacon-node-2 --restart on-failure:3 --security-opt="no-new-privileges=true" \
  gcr.io/prysmaticlabs/prysm/beacon-chain:v3.0.0 \
  --datadir=/data \
  --rpc-host=0.0.0.0 \
  --monitoring-host=0.0.0.0 \
  --http-web3provider=https://eth-mainnet.alchemyapi.io/v2/sCbtfxyKigCsKteX3M_pLT-KnboRLMcI \
  --fallback-web3provider=https://mainnet.infura.io/v3/e688007f8726451192c518e37fe0cdda \
  --log-file=/logs/beacon-node.log \
  --accept-terms-of-use \
  --monitoring-port=8082 \
  --p2p-tcp-port=13002 \
  --p2p-udp-port=12002 \
  --rpc-port=4002 \
  --p2p-max-peers 23 \
  --suggested-fee-recipient=0xa63Ce14Bc241812e3081A74b0b999b0D2bF0657F

#Generate key pairs
wget https://github.com/ethereum/staking-deposit-cli/releases/download/v2.1.0/staking_deposit-cli-ce8cbb6-linux-amd64.tar.gz
tar -xvzf staking_deposit-cli-ce8cbb6-linux-amd64.tar.gz
mv staking_deposit-cli-ce8cbb6-linux-amd64 staking_deposit-cli
cd staking_deposit-cli
./deposit existing-mnemonic --validator_start_index 7 --num_validators 1 --chain mainnet
create secret.txt

#Import your validator accounts into Prysm
#Node 1
docker run -it -v $HOME/staking_deposit-cli/validator_keys:/keys \
  -v /data/ethereum/node1/wallet:/wallet \
  --name validator-1 \
  gcr.io/prysmaticlabs/prysm/validator:v3.0.0 \
  accounts import --keys-dir=/keys --wallet-dir=/wallet

#Node 2
docker run -it -v $HOME/staking_deposit-cli/validator_keys:/keys \
  -v /data/ethereum/node2/wallet:/wallet \
  --name validator-2 \
  gcr.io/prysmaticlabs/prysm/validator:v3.0.0 \
  accounts import --keys-dir=/keys --wallet-dir=/wallet  

#Run your validator
#Node 1
docker run -d -v /data/ethereum/node1/wallet:/wallet -v /data/ethereum/node1/validatorDB:/validatorDB -v /data/ethereum/node1/logs:/logs \
  --network="host" --restart on-failure:3 --security-opt="no-new-privileges=true" \
  --name validator-1 gcr.io/prysmaticlabs/prysm/validator:v3.0.0 \
  --beacon-rpc-provider=127.0.0.1:4000 \
  --monitoring-host=0.0.0.0 \
  --wallet-dir=/wallet \
  --wallet-password-file=/wallet/secret.txt \
  --datadir=/validatorDB \
  --log-file=/logs/validator.log \
  --graffiti="Crypto Farmers" \
  --accept-terms-of-use \
  --suggested-fee-recipient=0xa63Ce14Bc241812e3081A74b0b999b0D2bF0657F

#Node 2
docker run -d -v /data/ethereum/node2/wallet:/wallet -v /data/ethereum/node2/validatorDB:/validatorDB -v /data/ethereum/node2/logs:/logs \
  --network="host" --restart on-failure:3 --security-opt="no-new-privileges=true" \
  --name validator-2 gcr.io/prysmaticlabs/prysm/validator:v3.0.0 \
  --beacon-rpc-provider=127.0.0.1:4002 \
  --monitoring-host=0.0.0.0 \
  --monitoring-port=8083 \
  --wallet-dir=/wallet \
  --wallet-password-file=/wallet/secret.txt \
  --datadir=/validatorDB \
  --log-file=/logs/validator.log \
  --graffiti="Crypto Farmers" \
  --accept-terms-of-use \
  --suggested-fee-recipient=0xa63Ce14Bc241812e3081A74b0b999b0D2bF0657F

#Run mev-boost per node
docker run -p 18550:18550 flashbots/mev-boost:latest -mainnet -relay-check -relays https://0xafa4c6985aa049fb79dd37010438cfebeb0f2bd42b115b89dd678dab0670c1de38da0c4e9138c9290a398ecd9a0b3110@builder-relay-goerli.flashbots.net
#Setup notification on beaconchain for the new node

------------------------------------