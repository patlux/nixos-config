#!/bin/bash

HC_URL="https://hc-ping.com/afb3d3a4-9e72-4b1d-baf0-cb88e60b5bb2"

trap 'curl -fsS -m 10 --retry 5 "$HC_URL/fail" > /dev/null 2>&1' ERR

set -e

cd /Users/patwoz/dev
echo "$(date)" Backing up $PWD ...
/etc/profiles/per-user/patwoz/bin/duplicacy -log backup -stats
echo "$(date)" Stopped backing up $PWD ...

curl -fsS -m 10 --retry 5 "$HC_URL" > /dev/null 2>&1
