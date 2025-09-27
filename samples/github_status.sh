#!/usr/bin/env bash

# GitHub Status Check Script for BAMON
# This script checks GitHub's status page API to verify service availability

# Simple one-liner command for BAMON
curl -s https://www.githubstatus.com/api/v2/status.json | jq -r '.status.indicator' | grep -q 'none' && echo 'Github ok' || echo 'Github not ok'
