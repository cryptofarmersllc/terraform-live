#Github: https://github.com/maticnetwork/polygon-cli

#Create wallet
polycli wallet create --addresses 5

#inspect wallet
polycli wallet inspect --addresses 5 --mnemonic "seed"

#Get private keys
polycli wallet inspect --addresses 5 --mnemonic "seed" | jq '.Addresses[].HexPrivateKey'

#Get addresses
polycli wallet inspect --addresses 5 --mnemonic "seed" | jq '.Addresses[].ETHAddress'
