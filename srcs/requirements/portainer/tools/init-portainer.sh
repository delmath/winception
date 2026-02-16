#!/bin/bash
echo "Waiting for Portainer to start..."
sleep 10

if wget -qO- http://localhost:9000/api/users/admin/check 2>/dev/null | grep -q "true"; then
    echo "Portainer is already initialized"
    exit 0
fi

PORTAINER_ADMIN_USER=${PORTAINER_ADMIN_USER}
PORTAINER_ADMIN_PASSWORD=${PORTAINER_ADMIN_PASSWORD}

curl -s -X POST http://localhost:9000/api/users/admin/init \
    -H "Content-Type: application/json" \
    -d "{
        \"Username\": \"$PORTAINER_ADMIN_USER\",
        \"Password\": \"$PORTAINER_ADMIN_PASSWORD\"
    }"

sleep 2

echo "Authenticating..."
TOKEN=$(curl -s -X POST http://localhost:9000/api/auth \
    -H "Content-Type: application/json" \
    -d "{
        \"Username\": \"$PORTAINER_ADMIN_USER\",
        \"Password\": \"$PORTAINER_ADMIN_PASSWORD\"
    }" | grep -o '"jwt":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "Failed to authenticate"
    exit 1
fi

echo "Token received: ${TOKEN:0:20}..."

echo "Creating Docker endpoint..."
RESPONSE=$(curl -s -X POST http://localhost:9000/api/endpoints \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "Name": "local-docker",
        "EndpointType": 1,
        "URL": "unix:///var/run/docker.sock",
        "GroupID": 1,
        "TLS": false,
        "TLSSkipVerify": false,
        "TLSSkipClientVerify": false
    }')

echo "$RESPONSE"

if echo "$RESPONSE" | grep -q '"Id"'; then
    echo "Endpoint created successfully!"
else
    echo "Note: Endpoint may already exist or creation had issues"
fi

echo "Initialization complete."
