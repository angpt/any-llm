#!/bin/bash
set -e

# JupyterLite + any-llm-gateway Integration Setup Script

echo "🚀 JupyterLite + any-llm-gateway Setup"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if gateway is running
echo -e "${BLUE}[1/4]${NC} Checking if any-llm-gateway is running..."
if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Gateway is running at http://localhost:3000"
else
    echo -e "${YELLOW}⚠${NC} Gateway is not running"
    echo "Please start it with: docker-compose -f ../../docker/docker-compose.yml up -d"
    exit 1
fi

# Get master key
echo ""
echo -e "${BLUE}[2/4]${NC} Please enter your gateway master key:"
read -s GATEWAY_MASTER_KEY
echo ""

# Create user
echo -e "${BLUE}[3/4]${NC} Creating JupyterLite user..."
USER_ID="jupyterlite-demo-$(date +%s)"

USER_RESPONSE=$(curl -s -X POST http://localhost:3000/v1/users \
  -H "X-AnyLLM-Key: Bearer ${GATEWAY_MASTER_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"user_id\": \"${USER_ID}\", \"alias\": \"JupyterLite Demo User\"}")

if echo "$USER_RESPONSE" | grep -q "user_id"; then
    echo -e "${GREEN}✓${NC} User created: ${USER_ID}"
else
    echo -e "${RED}✗${NC} Failed to create user"
    echo "Response: $USER_RESPONSE"
    exit 1
fi

# Create API key
echo -e "${BLUE}[4/4]${NC} Creating API key..."
KEY_RESPONSE=$(curl -s -X POST http://localhost:3000/v1/keys \
  -H "X-AnyLLM-Key: Bearer ${GATEWAY_MASTER_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"user_id\": \"${USER_ID}\", \"key_alias\": \"jupyterlite-demo-key\"}")

API_KEY=$(echo "$KEY_RESPONSE" | grep -o '"key":"[^"]*"' | cut -d'"' -f4)

if [ -n "$API_KEY" ]; then
    echo -e "${GREEN}✓${NC} API key created"
    echo ""
    echo "======================================"
    echo -e "${GREEN}Setup Complete!${NC}"
    echo "======================================"
    echo ""
    echo "Your API key:"
    echo -e "${YELLOW}${API_KEY}${NC}"
    echo ""
    echo "Configuration for jupyterlite-ai:"
    echo ""
    echo "{"
    echo "  \"baseURL\": \"http://localhost:3000/v1\","
    echo "  \"apiKey\": \"Bearer ${API_KEY}\","
    echo "  \"model\": \"openai:gpt-4\""
    echo "}"
    echo ""
    echo "Next steps:"
    echo "1. Open http://localhost:8080 (or serve this directory)"
    echo "2. Follow the setup instructions on the page"
    echo "3. Use the configuration above in jupyterlite-ai settings"
    echo ""
else
    echo -e "${RED}✗${NC} Failed to create API key"
    echo "Response: $KEY_RESPONSE"
    exit 1
fi
