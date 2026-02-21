#!/bin/sh

# This script is meant to be placed in /docker-entrypoint.d/
# and will be executed by the official nginx entrypoint script at startup.

set -e

# Find the config.json file. In Flutter web, assets are moved to assets/
# The path in the built container should be /usr/share/nginx/html/assets/assets/config.json 
# if listed as 'assets/' in pubspec.yaml, but let's check both possibilities.

FIND_PATHS="/usr/share/nginx/html/assets/config.json /usr/share/nginx/html/assets/assets/config.json"

for CONFIG_FILE in $FIND_PATHS; do
  if [ -f "$CONFIG_FILE" ]; then
    echo "[Config] Injecting runtime variables into $CONFIG_FILE"
    
    # Use sed to replace placeholders. Defaults are provided.
    sed -i "s|\$API_URL|${API_URL:-http://localhost:8080}|g" "$CONFIG_FILE"
    sed -i "s|\$ENVIRONMENT|${ENVIRONMENT:-production}|g" "$CONFIG_FILE"
    sed -i "s|\$FIREBASE_API_KEY|${FIREBASE_API_KEY:-}|g" "$CONFIG_FILE"
    sed -i "s|\$FIREBASE_AUTH_DOMAIN|${FIREBASE_AUTH_DOMAIN:-}|g" "$CONFIG_FILE"
    sed -i "s|\$FIREBASE_PROJECT_ID|${FIREBASE_PROJECT_ID:-}|g" "$CONFIG_FILE"
    sed -i "s|\$FIREBASE_STORAGE_BUCKET|${FIREBASE_STORAGE_BUCKET:-}|g" "$CONFIG_FILE"
    sed -i "s|\$FIREBASE_MESSAGING_SENDER_ID|${FIREBASE_MESSAGING_SENDER_ID:-}|g" "$CONFIG_FILE"
    sed -i "s|\$FIREBASE_APP_ID|${FIREBASE_APP_ID:-}|g" "$CONFIG_FILE"
    sed -i "s|\$FIREBASE_MEASUREMENT_ID|${FIREBASE_MEASUREMENT_ID:-}|g" "$CONFIG_FILE"
    
    # We found it, no need to check other paths.
    break
  fi
done
