#!/bin/bash

# Configuration Sync Script
# This script reads from config/secrets.json and populates various config files.
#
# Affected Files:
# - .env (Local/Docker Environment)
# - android/app/google-services.json (Android Firebase)
# - k8s/secret.yaml (Kubernetes Secret)
# - k8s/configmap.yaml (Kubernetes ConfigMap)

set -e

CONFIG_FILE="config/secrets.json"
TEMPLATES_DIR="config/templates"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found. Please create it from $CONFIG_FILE.example"
    exit 1
fi

echo "--- Starting Configuration Sync ---"

# Helper to get value from JSON using Python3
get_val() {
    python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['$1'])"
}

# 1. Sync .env for Local/Docker
echo "[1/4] Syncing .env..."
cat <<EOF > .env
API_URL=$(get_val API_URL)
ENVIRONMENT=$(get_val ENVIRONMENT)
BASE_HREF=$(get_val BASE_HREF)
FIREBASE_API_KEY=$(get_val FIREBASE_API_KEY)
FIREBASE_AUTH_DOMAIN=$(get_val FIREBASE_AUTH_DOMAIN)
FIREBASE_PROJECT_ID=$(get_val FIREBASE_PROJECT_ID)
FIREBASE_STORAGE_BUCKET=$(get_val FIREBASE_STORAGE_BUCKET)
FIREBASE_MESSAGING_SENDER_ID=$(get_val FIREBASE_MESSAGING_SENDER_ID)
FIREBASE_APP_ID=$(get_val FIREBASE_APP_ID)
FIREBASE_MEASUREMENT_ID=$(get_val FIREBASE_MEASUREMENT_ID)
EOF

# 2. Sync Android google-services.json
echo "[2/4] Syncing android/app/google-services.json..."
TEMPLATE="$TEMPLATES_DIR/google-services.json.template"
TARGET="android/app/google-services.json"

if [ -f "$TEMPLATE" ]; then
    mkdir -p android/app
    sed -e "s|{{FIREBASE_API_KEY}}|$(get_val FIREBASE_API_KEY)|g" \
        -e "s|{{FIREBASE_APP_ID}}|$(get_val FIREBASE_APP_ID)|g" \
        -e "s|{{FIREBASE_PROJECT_ID}}|$(get_val FIREBASE_PROJECT_ID)|g" \
        -e "s|{{FIREBASE_STORAGE_BUCKET}}|$(get_val FIREBASE_STORAGE_BUCKET)|g" \
        -e "s|{{FIREBASE_PROJECT_NUMBER}}|$(get_val FIREBASE_MESSAGING_SENDER_ID)|g" \
        -e "s|{{PACKAGE_NAME}}|$(get_val PACKAGE_NAME)|g" \
        -e "s|{{GOOGLE_CLIENT_ID}}|$(get_val GOOGLE_CLIENT_ID)|g" \
        "$TEMPLATE" > "$TARGET"
fi

# 3. Sync K8s Secret
echo "[3/4] Syncing k8s/secret.yaml..."
VAL_API_KEY=$(get_val FIREBASE_API_KEY)
VAL_APP_ID=$(get_val FIREBASE_APP_ID)
export FIREBASE_API_KEY_B64=$(echo -n "$VAL_API_KEY" | base64 | tr -d '\n')
export FIREBASE_APP_ID_B64=$(echo -n "$VAL_APP_ID" | base64 | tr -d '\n')
envsubst '${FIREBASE_API_KEY_B64},${FIREBASE_APP_ID_B64}' < "$TEMPLATES_DIR/secret.yaml.template" > k8s/secret.yaml

# 4. Sync K8s ConfigMap
echo "[4/4] Syncing k8s/configmap.yaml..."
export ENVIRONMENT=$(get_val ENVIRONMENT)
export API_URL=$(get_val API_URL)
export BASE_HREF=$(get_val BASE_HREF)
export FIREBASE_AUTH_DOMAIN=$(get_val FIREBASE_AUTH_DOMAIN)
export FIREBASE_PROJECT_ID=$(get_val FIREBASE_PROJECT_ID)
export FIREBASE_STORAGE_BUCKET=$(get_val FIREBASE_STORAGE_BUCKET)
export FIREBASE_MESSAGING_SENDER_ID=$(get_val FIREBASE_MESSAGING_SENDER_ID)
export FIREBASE_MEASUREMENT_ID=$(get_val FIREBASE_MEASUREMENT_ID)

VARS_LIST='${ENVIRONMENT},${API_URL},${BASE_HREF},${FIREBASE_AUTH_DOMAIN},${FIREBASE_PROJECT_ID},${FIREBASE_STORAGE_BUCKET},${FIREBASE_MESSAGING_SENDER_ID},${FIREBASE_MEASUREMENT_ID}'
envsubst "$VARS_LIST" < "$TEMPLATES_DIR/configmap.yaml.template" > k8s/configmap.yaml

echo "--- Sync Completed Successfully ---"
echo "Note: Files generated: .env, android/app/google-services.json, k8s/secret.yaml, k8s/configmap.yaml"
