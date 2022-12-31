FROM debian:stable-slim

ENV USER=defichain \
    HOME=/home/defichain \
    VERSION=3.2.0

RUN apt-get update \
    && apt-get full-upgrade \
    && apt-get install -y sudo wget \
    && useradd -m ${USER}

VOLUME ${HOME}/data

EXPOSE 8555

USER ${USER}

WORKDIR ${HOME}

RUN wget https://github.com/DeFiCh/ain/releases/download/v${VERSION}/defichain-${VERSION}-x86_64-pc-linux-gnu.tar.gz \
    && tar -xvzf defichain-${VERSION}-x86_64-pc-linux-gnu.tar.gz \
    && mkdir -p ${HOME}/.defi \
    && cp ./defichain-${VERSION}/bin/* ${HOME}/.defi \
    && rm -fr defichain-${VERSION} defichain-${VERSION}-x86_64-pc-linux-gnu.tar.gz

ENTRYPOINT [ "/home/defichain/.defi/defid", "-datadir=/home/defichain/data" ]
