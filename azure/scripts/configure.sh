#Run your executor node
#Node 1
docker run -d --name executor-node \
  -v /data/ethereum/execution:/root/.ethereum -v /data/ethereum/config:/root/config \
  -p 6060:6060 -p 8551:8551 -p 30303:30303/tcp -p 30303:30303/udp \
  --restart on-failure:3 --security-opt="no-new-privileges=true" \
  ethereum/client-go:v1.10.23 \
  --mainnet \
  --authrpc.addr 0.0.0.0 \
  --authrpc.jwtsecret=/root/config/jwt.hex \
  --http \
  --http.api eth,net,engine,admin \
  --metrics \
  --metrics.addr 0.0.0.0 \
  --snapshot=false

#Prune Geth
docker run -d --name prune-geth \
  -v /data/ethereum/data:/root/.ethereum \
  ethereum/client-go:v1.10.23 \
  snapshot prune-state \
  --mainnet

#Run your beacon node
docker run -d -v /data/ethereum/beacon:/data -v /data/ethereum/logs:/logs -v /data/ethereum/config:/config \
  --network="host" --name beacon-node-1 --restart on-failure:3 --security-opt="no-new-privileges=true" \
  gcr.io/prysmaticlabs/prysm/beacon-chain:v3.0.0 \
  --datadir=/data \
  --rpc-host=0.0.0.0 \
  --monitoring-host=0.0.0.0 \
  --execution-endpoint=http://localhost:8551 \
  --jwt-secret=/config/jwt.hex \
  --log-file=/logs/beacon-node.log \
  --accept-terms-of-use \
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
docker run -it --rm \
  -v $HOME/staking_deposit-cli/validator_keys:/keys -v /data/ethereum/node1/wallet:/wallet \
  gcr.io/prysmaticlabs/prysm/validator:v3.0.0 \
  accounts import --accept-terms-of-use \
  --keys-dir=/keys --account-password-file=/wallet/secret.txt \
  --wallet-dir=/wallet --wallet-password-file=/wallet/secret.txt
   

#List accounts
docker run -it --rm \
  -v /data/ethereum/node1/wallet:/wallet \
  gcr.io/prysmaticlabs/prysm/validator:v3.0.0 \
  accounts list --accept-terms-of-use --show-private-keys \
  --wallet-dir=/wallet --wallet-password-file=/wallet/secret.txt
  

#List validator indices
docker run -it --rm --network="host" \
  -v /data/ethereum/node1/wallet:/wallet \
  gcr.io/prysmaticlabs/prysm/validator:v3.0.0 \
  accounts list --accept-terms-of-use \
  --wallet-dir=/wallet --wallet-password-file=/wallet/secret.txt \
  --list-validator-indices --beacon-rpc-provider=127.0.0.1:4000

#Run your validator
docker run -d -v /data/ethereum/wallet:/wallet -v /data/ethereum/validatorDB:/validatorDB -v /data/ethereum/logs:/logs \
  --network="host" --restart on-failure:3 --security-opt="no-new-privileges=true" \
  --name validator-1 gcr.io/prysmaticlabs/prysm/validator:v3.0.0 \
  --beacon-rpc-provider=localhost:4000 \
  --monitoring-host=0.0.0.0 \
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

--------------------------------------------------------------------------------------------------------------------------
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
rsync --progress -avzhe "ssh -p 1122" use2lvalidator001prod:/data/ethereum/node1/beacon/beaconchaindata/beaconchain.db .
#Rsync beacon node database from source to destination node while source beacon node is stopped
rsync --progress -avzhe "ssh -p 1122" use2lvalidator002prod:/data/ethereum/node1/beacon/beaconchaindata/beaconchain.db .
#Remove private keys from destination node
rm -fr  ~/.ssh/id_rsa ~/.ssh/id_rsa.pub ~/.ssh/config

------------------------------------------------------------