#!/bin/bash

# CI Audit Script for Container Security and 12 Factor compliance
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "--- Starting CI Audit ---"

# 1. Container Security Check
echo "[1/2] Checking Container Security..."
if grep -q "USER" Dockerfile; then
    echo -e "${GREEN}PASS:${NC} USER instruction found in Dockerfile."
else
    echo -e "${RED}FAIL:${NC} USER instruction NOT found in Dockerfile. (Container security guidelines violation)"
    exit 1
fi

# 2. 12 Factor Config Check (Looking for hardcoded secrets)
echo "[2/2] Checking 12 Factor Compliance (Hardcoded Secrets)..."
SETTINGS_FILE="lib/services/config_service.dart"
if grep -q "firebase_api_key" "$SETTINGS_FILE"; then
    # Checking if it's actually reading from config or hardcoded
    if grep -q "_config\['firebase_api_key'\]" "$SETTINGS_FILE"; then
         echo -e "${GREEN}PASS:${NC} Firebase API key is loaded from configuration (12 Factor compliance)."
    else
         echo -e "${RED}FAIL:${NC} Potential hardcoded Firebase API key in $SETTINGS_FILE."
         exit 1
    fi
else
    echo -e "${GREEN}INFO:${NC} Firebase configuration check skipped (not found in expected file)."
fi

echo -e "\n${GREEN}CI Audit Completed Successfully!${NC}"
