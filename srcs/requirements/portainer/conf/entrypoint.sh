#!/bin/sh
set -e

echo "Starting Portainer..."
/opt/portainer/portainer --bind=:9000 --data=/data &
PORTAINER_PID=$!

echo "Portainer started with PID: $PORTAINER_PID"

/usr/local/bin/init-portainer.sh &

wait $PORTAINER_PID
