#!/usr/bin/env bats
# test/commands/test_list_command.bats

load "../container/test_helpers.sh"

@test "List command shows all configured scripts" {
  # Setup: Install BAMON and create test scripts
  install_bamon "user"
  
  # Add multiple test scripts
  run run_bamon "user" add "enabled_script" --command "echo 'enabled'" --interval 30 --enabled
  echo "=== ADD ENABLED SCRIPT DEBUG ==="
  echo "Exit code: $status"
  echo "Output: $output"
  
  run run_bamon "user" add "disabled_script" --command "echo 'disabled'" --interval 30 --disabled
  echo "Exit code: $status"
  echo "Output: $output"
  echo "========================="
  
  # List all scripts
  run run_bamon "user" list
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== LIST COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "Output: $output"
    echo "Config file contents:"
    cat "$BAMON_CONFIG_DIR/config.yaml" || echo "Config file not found"
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"enabled_script"* ]]
  [[ "$output" == *"disabled_script"* ]]
  [[ "$output" == *"enabled"* ]] || [[ "$output" == *"true"* ]]
  [[ "$output" == *"disabled"* ]] || [[ "$output" == *"false"* ]]
}

@test "List command shows only enabled scripts" {
  # Setup: Install BAMON and create test scripts
  install_bamon "user"
  
  # Add enabled and disabled scripts
  run run_bamon "user" add "enabled_script" --command "echo 'enabled'" --interval 30 --enabled
  run run_bamon "user" add "disabled_script" --command "echo 'disabled'" --interval 30 --disabled
  
  echo "=== ADD SCRIPTS DEBUG ==="
  echo "Enabled script add exit code: $status"
  echo "Enabled script add output: $output"
  
  run run_bamon "user" add "disabled_script" --command "echo 'disabled'" --interval 30 --disabled
  echo "Disabled script add exit code: $status"
  echo "Disabled script add output: $output"
  echo "========================="
  
  # List only enabled scripts
  run run_bamon "user" list --enabled-only
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== LIST --ENABLED-ONLY COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "Output: $output"
    echo "Config file contents:"
    cat "$BAMON_CONFIG_DIR/config.yaml" || echo "Config file not found"
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"enabled_script"* ]]
  [[ "$output" != *"disabled_script"* ]]
}

@test "List command shows only disabled scripts" {
  # Setup: Install BAMON and create test scripts
  install_bamon "user"
  
  # Add enabled and disabled scripts
  run run_bamon "user" add "enabled_script" --command "echo 'enabled'" --interval 30 --enabled
  run run_bamon "user" add "disabled_script" --command "echo 'disabled'" --interval 30 --disabled
  
  echo "=== ADD SCRIPTS DEBUG ==="
  echo "Enabled script add exit code: $status"
  echo "Enabled script add output: $output"
  
  run run_bamon "user" add "disabled_script" --command "echo 'disabled'" --interval 30 --disabled
  echo "Disabled script add exit code: $status"
  echo "Disabled script add output: $output"
  echo "========================="
  
  # List only disabled scripts
  run run_bamon "user" list --disabled-only
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== LIST --DISABLED-ONLY COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "Output: $output"
    echo "Config file contents:"
    cat "$BAMON_CONFIG_DIR/config.yaml" || echo "Config file not found"
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  [[ "$output" != *"enabled_script"* ]]
  [[ "$output" == *"disabled_script"* ]]
}

@test "List command shows help when no scripts configured" {
  # Setup: Install BAMON with no scripts
  install_bamon "user"
  
  # Remove default scripts if any
  run run_bamon "user" remove "health_check" --force 2>/dev/null || true
  run run_bamon "user" remove "disk_usage" --force 2>/dev/null || true
  run run_bamon "user" remove "github_status" --force 2>/dev/null || true
  
  # List scripts
  run run_bamon "user" list
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== LIST COMMAND WITH NO SCRIPTS FAILED ==="
    echo "Exit code: $status"
    echo "Output: $output"
    echo "Config file contents:"
    cat "$HOME/.config/bamon/config.yaml" || echo "Config file not found"
    echo "========================="
  fi
  
  # Debug output for unexpected content
  if [ "$status" -eq 0 ] && [[ -n "$output" ]] && [[ "$output" != *"No scripts configured"* ]]; then
    echo "=== LIST COMMAND WITH NO SCRIPTS UNEXPECTED OUTPUT ==="
    echo "Exit code: $status"
    echo "Output: $output"
    echo "Expected: 'No scripts configured' or empty output"
    echo "Config file contents:"
    cat "$HOME/.config/bamon/config.yaml" || echo "Config file not found"
    echo "========================="
  fi
  
  # Should either succeed with no output or show appropriate message
  if [ "$status" -eq 0 ]; then
    # If successful, should have minimal output or show "no scripts" message
    [ -z "$output" ] || [[ "$output" == *"no scripts"* ]] || [[ "$output" == *"No scripts"* ]] || [[ "$output" == *"empty"* ]]
  else
    # If failed, should show error message
    [[ "$output" == *"no scripts"* ]] || [[ "$output" == *"No scripts"* ]] || [[ "$output" == *"error"* ]] || [[ "$output" == *"Error"* ]]
  fi
}

@test "List command shows script details" {
  # Setup: Install BAMON and create a detailed script
  install_bamon "user"
  
  # Add a script with description and interval
  run run_bamon "user" add "detailed_script" --command "echo 'detailed test'" --interval 60 --description "A detailed test script"
  
  echo "=== ADD DETAILED SCRIPT DEBUG ==="
  echo "Exit code: $status"
  echo "Output: $output"
  echo "========================="
  
  # List scripts
  run run_bamon "user" list
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== LIST COMMAND DETAILS FAILED ==="
    echo "Exit code: $status"
    echo "Output: $output"
    echo "Config file contents:"
    cat "$BAMON_CONFIG_DIR/config.yaml" || echo "Config file not found"
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"detailed_script"* ]]
  # Should show some indication of the script details (description, interval, etc.)
  [[ "$output" == *"60"* ]] || [[ "$output" == *"detailed test"* ]] || [[ "$output" == *"A detailed test script"* ]]
}
