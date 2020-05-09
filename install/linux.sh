#!/bin/bash

# Install `bat` from https://github.com/sharkdp/bat
if ! command -v bat >/dev/null 2>&1; then
  BAT_VERSION=0.9.0
  wget https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat_${BAT_VERSION}_amd64.deb && \
      sudo dpkg -i bat_${BAT_VERSION}_amd64.deb && \
      rm bat_${BAT_VERSION}_amd64.deb
fi

# Install `fd` from https://github.com/sharkdp/fd/
if ! command -v fd >/dev/null 2>&1; then
  FD_VERSION=7.2.0
  wget https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd_${FD_VERSION}_amd64.deb && \
      sudo dpkg -i fd_${FD_VERSION}_amd64.deb && \
      rm fd_${FD_VERSION}_amd64.deb
fi

sudo apt-get install \
   ack-grep \
   jq \
   magic-wormhole \
   ncdu \
   npm

