#!/usr/bin/env bash

# Debug execution flow
source src/lib/config.sh
source src/lib/logging.sh
source src/lib/sandbox.sh
source src/lib/execution.sh

echo "Testing execution flow..."

# Initialize config
init_config
load_config

# Test the execute_script function directly
script_name="failing_test"
script_command="echo failing_test_echo && exit 1"

echo "1. Testing execute_script function..."
execute_script "$script_name" "$script_command"
