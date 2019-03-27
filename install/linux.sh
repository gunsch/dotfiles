#!/bin/bash

# Install `bat` from https://github.com/sharkdp/bat
BAT_VERSION=0.9.0
wget https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat_${BAT_VERSION}_amd64.deb && \
    sudo dpkg -i bat_${BAT_VERSION}_amd64.deb && \
    rm bat_${BAT_VERSION}_amd64.deb

# Install `fd` from https://github.com/sharkdp/fd/
FD_VERSION=7.2.0
wget https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd_${FD_VERSION}_amd64.deb && \
    sudo dpkg -i fd_${FD_VERSION}_amd64.deb && \
    rm fd_${FD_VERSION}_amd64.deb

sudo apt-get install \
   ack \
   jq \
   ncdu

