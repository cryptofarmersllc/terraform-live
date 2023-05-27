FROM ubuntu:jammy

ENV PATH=/home/theta/mainnet/bin:$PATH

RUN apt update \
    && apt upgrade -y \
    && useradd -m theta \
    && apt install -y curl wget

USER theta

RUN mkdir -p /home/theta/mainnet/bin /home/theta/mainnet/guardian/node \
    && cd /home/theta/mainnet \
    && curl -sk -o bin/theta $(curl -k 'https://mainnet-data.thetatoken.org/binary?os=linux&name=theta') \
    && curl -sk -o bin/thetacli $(curl -k 'https://mainnet-data.thetatoken.org/binary?os=linux&name=thetacli') \
    && chmod +x bin/theta bin/thetacli

WORKDIR /home/theta/mainnet/bin

ENTRYPOINT ["/home/theta/mainnet/bin/theta"]



