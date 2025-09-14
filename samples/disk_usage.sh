#!/usr/bin/env bash

# Disk Usage Monitor Script for BAMON
# This script checks disk usage and alerts if it's too high

# Configuration
THRESHOLD=80  # Alert if disk usage is above 80%
MOUNT_POINT="/"  # Check root filesystem

# Get disk usage percentage
usage=$(df -h "$MOUNT_POINT" | awk 'NR==2 {print $5}' | sed 's/%//')

# Check if usage is above threshold
if [[ "$usage" -gt "$THRESHOLD" ]]; then
    echo "WARNING: Disk usage is ${usage}% (threshold: ${THRESHOLD}%)"
    exit 1
else
    echo "Disk usage: ${usage}% (OK)"
    exit 0
fi
