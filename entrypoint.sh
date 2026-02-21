#!/bin/sh

# Replace environment variables in config template
# Using envsubst if available, or sed for simple replacements
# Flutter assets are served from /usr/share/nginx/html/assets/

CONFIG_FILE="/usr/share/nginx/html/assets/config.json"

if [ -f "$CONFIG_FILE" ]; then
  echo "Injecting runtime configuration..."
  # Example using sed to replace placeholders
  sed -i "s|\$API_URL|${API_URL:-http://localhost:8080}|g" "$CONFIG_FILE"
  sed -i "s|\$ENVIRONMENT|${ENVIRONMENT:-production}|g" "$CONFIG_FILE"
  sed -i "s|\$FIREBASE_API_KEY|${FIREBASE_API_KEY:-}|g" "$CONFIG_FILE"
  sed -i "s|\$FIREBASE_AUTH_DOMAIN|${FIREBASE_AUTH_DOMAIN:-}|g" "$CONFIG_FILE"
  sed -i "s|\$FIREBASE_PROJECT_ID|${FIREBASE_PROJECT_ID:-}|g" "$CONFIG_FILE"
  sed -i "s|\$FIREBASE_STORAGE_BUCKET|${FIREBASE_STORAGE_BUCKET:-}|g" "$CONFIG_FILE"
  sed -i "s|\$FIREBASE_MESSAGING_SENDER_ID|${FIREBASE_MESSAGING_SENDER_ID:-}|g" "$CONFIG_FILE"
  sed -i "s|\$FIREBASE_APP_ID|${FIREBASE_APP_ID:-}|g" "$CONFIG_FILE"
  sed -i "s|\$FIREBASE_MEASUREMENT_ID|${FIREBASE_MEASUREMENT_ID:-}|g" "$CONFIG_FILE"
else
  echo "Config file not found at $CONFIG_FILE"
fi

# Start Nginx
exec nginx -g "daemon off;"
