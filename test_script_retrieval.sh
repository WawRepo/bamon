#!/usr/bin/env bash

# Test script retrieval and performance tracking
source src/lib/config.sh
source src/lib/performance.sh

echo "Testing script retrieval and performance tracking..."

echo "1. Testing get_all_scripts..."
scripts_json=$(get_all_scripts)
echo "   Scripts JSON: $scripts_json"

echo "2. Testing get_enabled_scripts..."
enabled_scripts=$(get_enabled_scripts)
echo "   Enabled scripts:"
echo "$enabled_scripts"

echo "3. Testing track_script_execution with real script names..."
if [[ -n "$enabled_scripts" ]]; then
  while IFS= read -r script_name; do
    if [[ -n "$script_name" ]]; then
      track_script_execution "$script_name" "2" "true"
      echo "   Tracked: $script_name (2s, success)"
    fi
  done <<< "$enabled_scripts"
fi

echo "4. Testing performance report..."
generate_performance_report
