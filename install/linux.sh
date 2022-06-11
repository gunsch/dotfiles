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

if [ ! -e /etc/apt/sources.list.d/google-chrome.list ]; then
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
  sudo apt update
fi

if [ ! -e /etc/apt/sources.list.d/github-cli.list ]; then
  wget -q https://cli.github.com/packages/githubcli-archive-keyring.gpg -O - | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
fi

if [ ! -e /etc/apt/sources.list.d/signal-xenial.list ]; then
	wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
	cat signal-desktop-keyring.gpg | sudo tee -a /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null

	echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
		sudo tee -a /etc/apt/sources.list.d/signal-xenial.list
  sudo apt update
fi


# Ubuntu 20.04 installs node 10, but npm doesn't work with node 10 anymore.
# Need to upgrade first, then use npm -> n -> node to get latest
# This section can be removed if Ubuntu starts shipping newer node versions with default OS.
node_version=$(node --version)
if [ ${node_version:1:2} -lt 12 ]; then
    ## Update NodeJS
    curl -fsSL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Update node via npm -> n
sudo npm install -g n
sudo n stable

sudo apt-get install \
   ack \
   chrome-gnome-shell \
   curl \
   git \
   google-chrome-stable \
   htop \
   jq \
   magic-wormhole \
   mosh \
   ncdu \
	 signal-desktop \
   terminator \
   vim

