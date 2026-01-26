#!/bin/sh

# Start Portainer in the background
/opt/portainer/portainer --bind=:9000 --no-analytics &

# Run initialization script in background
/usr/local/bin/init-portainer.sh &

# Wait for Portainer process
wait $!
