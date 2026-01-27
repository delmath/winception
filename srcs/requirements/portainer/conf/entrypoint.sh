#!/bin/sh
/opt/portainer/portainer --bind=:9000 --no-analytics &
PORTAINER_PID=$!

/usr/local/bin/init-portainer.sh &

wait $PORTAINER_PID
