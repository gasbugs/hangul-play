#!/bin/bash

# Script to sync .env to assets/config.json for local development

if [ ! -f .env ]; then
  echo "Error: .env file not found! Copy .env.example to .env and fill in your values."
  exit 1
fi

# Load .env variables
export $(grep -v '^#' .env | xargs)

CONFIG_FILE="assets/config.json"
TEMPLATE='{
  "api_url": "$API_URL",
  "environment": "$ENVIRONMENT",
  "firebase_api_key": "$FIREBASE_API_KEY",
  "firebase_auth_domain": "$FIREBASE_AUTH_DOMAIN",
  "firebase_project_id": "$FIREBASE_PROJECT_ID",
  "firebase_storage_bucket": "$FIREBASE_STORAGE_BUCKET",
  "firebase_messaging_sender_id": "$FIREBASE_MESSAGING_SENDER_ID",
  "firebase_app_id": "$FIREBASE_APP_ID",
  "firebase_measurement_id": "$FIREBASE_MEASUREMENT_ID"
}'

echo "Synchronizing .env to $CONFIG_FILE..."

# Replace placeholders using envsubst
if command -v envsubst >/dev/null 2>&1; then
  echo "$TEMPLATE" | envsubst > "$CONFIG_FILE"
else
  # Fallback to sed if envsubst is not available
  cp assets/config.json assets/config.json.bak
  echo "$TEMPLATE" > "$CONFIG_FILE"
  
  sed -i "s|\$API_URL|${API_URL}|g" "$CONFIG_FILE"
  sed -i "s|\$ENVIRONMENT|${ENVIRONMENT}|g" "$CONFIG_FILE"
  sed -i "s|\$FIREBASE_API_KEY|${FIREBASE_API_KEY}|g" "$CONFIG_FILE"
  sed -i "s|\$FIREBASE_AUTH_DOMAIN|${FIREBASE_AUTH_DOMAIN}|g" "$CONFIG_FILE"
  sed -i "s|\$FIREBASE_PROJECT_ID|${FIREBASE_PROJECT_ID}|g" "$CONFIG_FILE"
  sed -i "s|\$FIREBASE_STORAGE_BUCKET|${FIREBASE_STORAGE_BUCKET}|g" "$CONFIG_FILE"
  sed -i "s|\$FIREBASE_MESSAGING_SENDER_ID|${FIREBASE_MESSAGING_SENDER_ID}|g" "$CONFIG_FILE"
  sed -i "s|\$FIREBASE_APP_ID|${FIREBASE_APP_ID}|g" "$CONFIG_FILE"
  sed -i "s|\$FIREBASE_MEASUREMENT_ID|${FIREBASE_MEASUREMENT_ID}|g" "$CONFIG_FILE"
fi

echo "Done! assets/config.json updated."
