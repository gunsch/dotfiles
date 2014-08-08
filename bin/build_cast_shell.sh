#!/usr/bin/env bash
# Builds cast_shell once in an existing chromium checkout.

set -e

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <path to chromium/src>" 1>&2;
  exit 1;
fi

cd $1;
export GYP_GENERATOR_FLAGS="output_dir=out_chromecast"
export GYP_DEFINES="chromecast=1"

git pull origin master
gclient sync
ninja -C out_chromecast/Debug cast_shell