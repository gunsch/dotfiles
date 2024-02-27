#!/bin/bash

# Install or update plex media server
if ! systemctl list-unit-files plexmediaserver.service > /dev/null; then
  # One-time: set up auto-plex-installer
  bash -c "$(wget -qO - https://raw.githubusercontent.com/mrworf/plexupdate/master/extras/installer.sh)"
fi

# Takes an arg (service name) and stdin (override file contents) and sets everything up.
# Pretty janky, but works as long as none of the commands besides `tee` get thrown
# off by the stdin.
function systemd_override() {
  echo "Checking if $1.service needs an override..."
  if [ ! -f /etc/systemd/system/$1.service.d/10-override.conf ]; then
    echo "Setting up systemd override for $1"
    sudo systemctl stop $1
    sudo mkdir -p /etc/systemd/system/$1.service.d/
    sudo tee /etc/systemd/system/$1.service.d/10-override.conf
    sudo systemctl daemon-reload
    sudo systemctl start $1
    echo "$1 restarted!"
  fi
}

#########################################
# Transmission systemd override
systemd_override transmission-daemon <<EOF
[Service]
User=${USER}
ExecStart=
ExecStart=/usr/bin/transmission-daemon -f --log-info --logfile /tmp/transmission.log
EOF

#########################################
# Plex systemd override
systemd_override plexmediaserver <<EOF
[Service]
Environment="PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/home/plex/Library/Application Support"
EOF

#########################################
# Sonar install and override
if [ ! -d /var/lib/sonarr ]; then
  # One-time: do a curl|bash install :(
  wget -qO- https://raw.githubusercontent.com/Sonarr/Sonarr/develop/distribution/debian/install.sh | sudo bash
fi
# Change data directory to something home-mounted
systemd_override sonarr <<EOF
[Service]
ExecStart=
ExecStart=/opt/Sonarr/Sonarr -nobrowser -data=/home/sonarr/.config/Sonarr/
EOF

#########################################
# Set up syncthing
if [ -f /etc/apt/keyrings/syncthing-archive-keyring.gpg ]; then
  sudo mkdir -p /etc/apt/keyrings
  sudo curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
fi
if [ -f /etc/apt/sources.list.d/syncthing.list ]; then
  echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing candidate" | sudo tee /etc/apt/sources.list.d/syncthing.list
  sudo apt update
fi
if ! systemctl is-enabled syncthing@.service > /dev/null; then
  echo "Starting syncthing as user ${USER}"
  sudo systemctl enable syncthing@${USER}.service
  sudo systemctl start syncthing@${USER}.service
fi

