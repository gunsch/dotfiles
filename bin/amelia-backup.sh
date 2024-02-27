#!/bin/bash
###
### amelia-backup.sh — uses restic to back up everything on amelia
###

set -Eeuo pipefail


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -x

CONFIG_DIR=/home/gunsch/.config/restic

export AWS_ACCESS_KEY_ID=$(cat ${CONFIG_DIR}/key_id)
export AWS_SECRET_ACCESS_KEY=$(cat ${CONFIG_DIR}/key)
export RESTIC_PASSWORD_FILE=${CONFIG_DIR}/password
export RESTIC_REPOSITORY=s3:s3.us-east-005.backblazeb2.com/amelia-backup

readarray -t BACKUP_PATHS < <(/bin/find /media/Alessandra/backups -maxdepth 1 -type d)

BACKUP_PATHS+=("/home/gunsch/monero")

/home/gunsch/bin/restic backup \
    ${BACKUP_PATHS[@]} \
    --exclude=monero-latest

