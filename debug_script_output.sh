#!/usr/bin/env bash

# Debug script output capture
source src/lib/sandbox.sh
source src/lib/logging.sh

echo "Testing script output capture..."

# Test the failing_test command directly
script_name="failing_test"
command="echo failing_test_echo && exit 1"

echo "1. Testing execute_sandboxed_from_config directly..."
result=$(execute_sandboxed_from_config "$script_name" "$command")
echo "   Result: '$result'"

# Parse the result
if [[ "$result" =~ ^([0-9]+):(.*)$ ]]; then
  exit_code="${BASH_REMATCH[1]}"
  output="${BASH_REMATCH[2]}"
  echo "   Exit code: $exit_code"
  echo "   Output: '$output'"
else
  echo "   Failed to parse result"
fi

echo "2. Testing execute_sandboxed directly..."
result2=$(execute_sandboxed "$script_name" "$command" "30")
echo "   Result: '$result2'"

# Parse the result
if [[ "$result2" =~ ^([0-9]+):(.*)$ ]]; then
  exit_code2="${BASH_REMATCH[1]}"
  output2="${BASH_REMATCH[2]}"
  echo "   Exit code: $exit_code2"
  echo "   Output: '$output2'"
else
  echo "   Failed to parse result"
fi
