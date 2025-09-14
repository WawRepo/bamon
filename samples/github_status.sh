#!/usr/bin/env bash

# GitHub Status Check Script for BAMON
# This script checks GitHub's status page API to verify service availability

# Configuration
API_URL="https://www.githubstatus.com/api/v2/status.json"
TIMEOUT=10

# Perform GitHub status check
echo "Checking GitHub status..."

# Use curl with timeout to get the status
response=$(curl -s --max-time $TIMEOUT "$API_URL" 2>/dev/null)

if [[ $? -ne 0 ]]; then
    echo "ERROR: Failed to connect to GitHub status API"
    exit 1
fi

# Check if response is valid JSON and contains status information
if ! echo "$response" | jq -e '.status.indicator' > /dev/null 2>&1; then
    echo "ERROR: Invalid response from GitHub status API"
    exit 1
fi

# Extract status indicator
status_indicator=$(echo "$response" | jq -r '.status.indicator')
status_description=$(echo "$response" | jq -r '.status.description')

# Check if GitHub is operational (indicator should be "none" for all systems operational)
if [[ "$status_indicator" == "none" ]]; then
    echo "GitHub is operational: $status_description"
    exit 0
else
    echo "GitHub has issues: $status_description (Status: $status_indicator)"
    exit 1
fi
