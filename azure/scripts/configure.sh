# Run your beacon node
docker run -d -h validator1.cryptofarmers.io -v /data/ethereum:/data -p 4000:4000 -p 13000:13000 -p 12000:12000/udp \
  --name beacon-node --restart on-failure:3 --security-opt="no-new-privileges=true" \
  gcr.io/prysmaticlabs/prysm/beacon-chain:stable \
  --datadir=/data \
  --rpc-host=0.0.0.0 \
  --monitoring-host=0.0.0.0 \
  --http-web3provider=https://mainnet.infura.io/v3/e688007f8726451192c518e37fe0cdda \
  --fallback-web3provider=https://eth-mainnet.alchemyapi.io/v2/sCbtfxyKigCsKteX3M_pLT-KnboRLMcI \
  --log-file=/logs/beacon-node.log \
  --accept-terms-of-use

# Import your validator accounts into Prysm
docker run -it -v $HOME/eth2-deposit-cli/validator_keys:/keys \
  -v /data/ethereum/wallet:/wallet \
  --name validator \
  gcr.io/prysmaticlabs/prysm/validator:stable \
  accounts import --keys-dir=/keys --wallet-dir=/wallet

  # Run your validator
docker run -d -h validator1.cryptofarmers.io -v /data/ethereum/wallet:/wallet \
  -v /data/ethereum/validatorDB:/validatorDB -v /data/ethereum/logs:/logs \
  --network="host" --name validator --restart on-failure:3 --security-opt="no-new-privileges=true" \
  gcr.io/prysmaticlabs/prysm/validator:stable \
  --beacon-rpc-provider=127.0.0.1:4000 \
  --monitoring-host=0.0.0.0 \
  --wallet-dir=/wallet \
  --wallet-password-file=/wallet/secret.txt \
  --datadir=/validatorDB \
  --log-file=/logs/validator.log \
  --graffiti="Crypto Farmers Node 1: Happy to attest for Tony Paul Antony" \
  --accept-terms-of-use
