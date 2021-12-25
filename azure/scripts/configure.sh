#Rsync beacon node database
#Copy private key to destination node
scp ~/.ssh/id_rsa ~/.ssh/id_rsa.pub ~/.ssh/config validator2.cryptofarmers.io:/home/groot/.ssh/
#verify ssh connection is established from destination to source node
ssh use2lvalidator001prod -p 1122
exit
#Rsync beacon node database from source to destination node while source beacon node is running
cd /data/ethereum/beacon
mkdir beaconchaindata
cd beaconchaindata
rsync --progress -avzhe "ssh -p 1122" use2lvalidator002prod:/data/ethereum/beacon/beaconchaindata/beaconchain.db .
#Rsync beacon node database from source to destination node while source beacon node is stopped
rsync --progress -avzhe "ssh -p 1122" use2lvalidator002prod:/data/ethereum/beacon/beaconchaindata/beaconchain.db .
#Remove private keys from destination node
rm -fr  ~/.ssh/id_rsa ~/.ssh/id_rsa.pub ~/.ssh/config

------------------------------------------------------------
#Run your beacon node
docker run -d -v /data/ethereum/beacon:/data -v /data/ethereum/logs:/logs \
  -p 4000:4000 -p 8080:8080 -p 13000:13000 -p 12000:12000/udp \
  --name beacon-node --restart on-failure:3 --security-opt="no-new-privileges=true" \
  gcr.io/prysmaticlabs/prysm/beacon-chain:v2.0.5 \
  --datadir=/data \
  --rpc-host=0.0.0.0 \
  --monitoring-host=0.0.0.0 \
  --http-web3provider=https://mainnet.infura.io/v3/e688007f8726451192c518e37fe0cdda \
  --fallback-web3provider=https://eth-mainnet.alchemyapi.io/v2/sCbtfxyKigCsKteX3M_pLT-KnboRLMcI \
  --log-file=/logs/beacon-node.log \
  --accept-terms-of-use

#Generate key pairs
wget https://github.com/ethereum/eth2.0-deposit-cli/releases/download/v1.2.0/eth2deposit-cli-256ea21-linux-amd64.tar.gz
tar -xvzf eth2deposit-cli-256ea21-linux-amd64.tar.gz
mv eth2deposit-cli-256ea21-linux-amd64 eth2deposit-cli
cd eth2deposit-cli
./deposit existing-mnemonic --validator_start_index 2 --num_validators 2 --chain mainnet
create secret.txt

#Import your validator accounts into Prysm
docker run -it -v $HOME/eth2deposit-cli/validator_keys:/keys \
  -v /data/ethereum/wallet:/wallet \
  --name validator \
  gcr.io/prysmaticlabs/prysm/validator:v2.0.5 \
  accounts import --keys-dir=/keys --wallet-dir=/wallet

#Run your validator
docker run -d -v /data/ethereum/wallet:/wallet -v /data/ethereum/validatorDB:/validatorDB -v /data/ethereum/logs:/logs \
  --network="host" --restart on-failure:3 --security-opt="no-new-privileges=true" \
  --name validator gcr.io/prysmaticlabs/prysm/validator:v2.0.5 \
  --beacon-rpc-provider=127.0.0.1:4000 \
  --monitoring-host=0.0.0.0 \
  --wallet-dir=/wallet \
  --wallet-password-file=/wallet/secret.txt \
  --datadir=/validatorDB \
  --log-file=/logs/validator.log \
  --graffiti="Crypto Farmers Node 5" \
  --accept-terms-of-use

#Setup notification on beaconchain for the new node

------------------------------------