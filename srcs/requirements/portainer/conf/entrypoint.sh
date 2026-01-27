#!/bin/sh
set -e
/usr/local/bin/init-portainer.sh

echo "Starting Portainer..."

exec /opt/portainer/portainer \
  --bind=:9000 \
  --no-analytics
