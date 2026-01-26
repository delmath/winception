#!/bin/sh

# Wait for Portainer to be ready
echo "Waiting for Portainer to start..."
sleep 10

# Check if Portainer is already initialized
if wget -qO- http://localhost:9000/api/users/admin/check 2>/dev/null | grep -q "true"; then
    echo "Portainer is already initialized"
    exit 0
fi

# Use environment variables with defaults
PORTAINER_ADMIN_USER=${PORTAINER_ADMIN_USER:-admin}
PORTAINER_ADMIN_PASSWORD=${PORTAINER_ADMIN_PASSWORD:-portainer123}

# Initialize admin user
echo "Creating admin user: $PORTAINER_ADMIN_USER"
curl -s -X POST http://localhost:9000/api/users/admin/init \
    -H "Content-Type: application/json" \
    -d "{
        \"Username\": \"$PORTAINER_ADMIN_USER\",
        \"Password\": \"$PORTAINER_ADMIN_PASSWORD\"
    }"

# Wait a bit for user creation
sleep 2

# Get authentication token
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

# Initialize Docker endpoint
echo "Creating Docker endpoint..."
curl -s -X POST http://localhost:9000/api/endpoints \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "Name": "local",
        "EndpointCreationType": 1,
        "URL": "unix:///var/run/docker.sock",
        "PublicURL": "",
        "GroupID": 1,
        "TLS": false
    }'

echo ""
echo "================================"
echo "Portainer initialized successfully!"
echo "Username: $PORTAINER_ADMIN_USER"
echo "Password: $PORTAINER_ADMIN_PASSWORD"
echo "Access via: https://$DOMAIN_NAME/portainer/"
echo "================================"
