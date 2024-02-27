#!/bin/bash

CONFIG=$HOME/.config/gphotos-sync
STORAGE=/media/Alessandra/backups/google-photos

/snap/bin/docker run --rm -v $CONFIG:/config -v $STORAGE:/storage -p 8080:8080 ghcr.io/gilesknap/gphotos-sync /storage

