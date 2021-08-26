docker run -d -h validator1.cryptofarmers.io -v /data/ethereum:/data -p 4000:4000 -p 13000:13000 -p 12000:12000/udp \
  --name beacon-node --restart on-failure:3 --security-opt="no-new-privileges=true" \
  gcr.io/prysmaticlabs/prysm/beacon-chain:stable \
  --datadir=/data \
  --rpc-host=0.0.0.0 \
  --monitoring-host=0.0.0.0 \
  --http-web3provider=https://mainnet.infura.io/v3/e688007f8726451192c518e37fe0cdda \
  --accept-terms-of-use