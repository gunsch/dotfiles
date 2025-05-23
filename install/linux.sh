#!/bin/bash

DOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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

# Install chrome latest
if ! command -v google-chrome >/dev/null 2>&1; then
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
      sudo apt install ./google-chrome-stable_current_amd64.deb && \
      rm google-chrome-stable_current_amd64.deb
fi

# TODO: after ubuntu 24.04, add gnome-browser-connector
# Until then, install it manually using this:
# https://github.com/8Ten10/Fix-Gnome-Extensions-Your-native-host-connector-do-not-support-following-APIs-v6-
sudo apt -y install \
   ack \
   curl \
   git \
   htop \
   jq \
   magic-wormhole \
   mosh \
   ncdu \
   scdaemon \
   terminator \
   transmission-cli \
   transmission-daemon \
   vim

function snap_install() {
  snap_name=${@: -1}
  if ! snap list "${snap_name}" > /dev/null; then
    echo "Installing ${snap_name}..."
    # If there's already an installed set of data, install the same revision to reuse data.
    if [ -d ${HOME}/snap/${snap_name}/current ]; then
      snap_revision=$(basename $(readlink -f ${HOME}/snap/${snap_name}/current))
      sudo snap install $@ --revision=${snap_revision}
      # Then immediately refresh to update to latest
      sudo snap refresh $@
    else
      sudo snap install $@
    fi
  fi
}

# Binaries I like to have installed
# code requires --classic to have system access
snap_install --classic code
snap_install canonical-livepatch
snap_install discord
snap_install docker
snap_install gh
snap_install signal-desktop
snap_install slack
snap_install spotify
snap_install telegram-desktop
snap_install vlc

#####################################################
# Re-install crontab, if there's a host-specific one.
if [ -f $DOT/host/$(hostname -s).crontab ]; then
  backup_spot="backups/config/$(hostname -s).crontab.$(date +%s)"
  crontab -l > ${backup_spot}
  echo "Previous crontab saved at ${backup_spot}"

  crontab ${DOT}/host/$(hostname -s).crontab
  echo "Installed $(hostname -s).crontab"
fi
