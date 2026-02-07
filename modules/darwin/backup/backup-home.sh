#!/bin/bash

HC_URL="https://hc-ping.com/d2a18847-399f-4a38-a846-9e68e1912a17"

trap 'curl -fsS -m 10 --retry 5 "$HC_URL/fail" > /dev/null 2>&1' ERR

set -e

cd /Users/patwoz
echo "$(date)" Backing up $PWD ...
/etc/profiles/per-user/patwoz/bin/duplicacy -log backup -stats
echo "$(date)" Stopped backing up $PWD ...

curl -fsS -m 10 --retry 5 "$HC_URL" > /dev/null 2>&1
