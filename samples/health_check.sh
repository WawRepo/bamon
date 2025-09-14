#!/usr/bin/env bash

# Health Check Script for BAMON
# This script performs a simple HTTP health check

# Configuration
URL="https://httpbin.org/status/200"
TIMEOUT=10

# Perform health check
response_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time $TIMEOUT "$URL" 2>/dev/null)

if [[ "$response_code" == "200" ]]; then
    echo "Health check passed: HTTP $response_code"
    exit 0
else
    echo "Health check failed: HTTP $response_code"
    exit 1
fi
