#!/bin/sh

set -e # stop on error

cd /Users/patwoz
echo "$(date)" Backing up $PWD ...
/etc/profiles/per-user/patwoz/bin/duplicacy -log backup -stats
echo "$(date)" Stopped backing up $PWD ...

curl -m 10 --retry 5 https://hc-ping.com/d2a18847-399f-4a38-a846-9e68e1912a17
