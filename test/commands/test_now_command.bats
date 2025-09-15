#!/usr/bin/env bats
# test/commands/test_now_command.bats

load "../container/test_helpers.sh"

@test "Now command executes all enabled scripts" {
  # Setup: Install BAMON and create test scripts
  install_bamon "user"
  
  # Add a test script
  run run_bamon "user" add "test_script" --command "echo 'test output'" --interval 30
  echo "=== ADD SCRIPT DEBUG ==="
  echo "Exit code: $status"
  echo "Output: $output"
  echo "========================="
  
  [ "$status" -eq 0 ]
  
  # Execute all scripts immediately
  run run_bamon "user" now
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== NOW COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "Output: $output"
    echo "Config file contents:"
    cat "$BAMON_CONFIG_DIR/config.yaml" || echo "Config file not found"
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"test output"* ]]
}

@test "Now command executes specific script by name" {
  # Setup: Install BAMON and create test scripts
  install_bamon "user"
  
  # Add multiple test scripts
  run run_bamon "user" add "script1" --command "echo 'script1 output'" --interval 30
  run run_bamon "user" add "script2" --command "echo 'script2 output'" --interval 30
  
  echo "=== ADD SCRIPTS DEBUG ==="
  echo "Script1 add exit code: $status"
  echo "Script1 add output: $output"
  
  run run_bamon "user" add "script2" --command "echo 'script2 output'" --interval 30
  echo "Script2 add exit code: $status"
  echo "Script2 add output: $output"
  echo "========================="
  
  # Execute only script1
  run run_bamon "user" now --name "script1"
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== NOW --NAME COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "Output: $output"
    echo "Config file contents:"
    cat "$BAMON_CONFIG_DIR/config.yaml" || echo "Config file not found"
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"script1 output"* ]]
  [[ "$output" != *"script2 output"* ]]
}



@test "Now command shows help when no scripts configured" {
  # Setup: Install BAMON with no scripts
  install_bamon "user"
  
  # Remove default scripts if any
  run run_bamon "user" remove "health_check" --force 2>/dev/null || true
  run run_bamon "user" remove "disk_usage" --force 2>/dev/null || true
  run run_bamon "user" remove "github_status" --force 2>/dev/null || true
  
  # Execute now command
  run run_bamon "user" now
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== NOW COMMAND WITH NO SCRIPTS FAILED ==="
    echo "Exit code: $status"
    echo "Output: $output"
    echo "Config file contents:"
    cat "$HOME/.config/bamon/config.yaml" || echo "Config file not found"
    echo "========================="
  fi
  
  # Debug output for unexpected content
  if [ "$status" -eq 0 ] && [[ -n "$output" ]] && [[ "$output" != *"No scripts"* ]]; then
    echo "=== NOW COMMAND WITH NO SCRIPTS UNEXPECTED OUTPUT ==="
    echo "Exit code: $status"
    echo "Output: $output"
    echo "Expected: 'No scripts' message or empty output"
    echo "Config file contents:"
    cat "$HOME/.config/bamon/config.yaml" || echo "Config file not found"
    echo "========================="
  fi
  
  # Should either succeed with no output or show appropriate message
  if [ "$status" -eq 0 ]; then
    # If successful, should have minimal output
    [ -z "$output" ] || [[ "$output" == *"no scripts"* ]] || [[ "$output" == *"No scripts"* ]]
  else
    # If failed, should show error message
    [[ "$output" == *"no scripts"* ]] || [[ "$output" == *"No scripts"* ]] || [[ "$output" == *"error"* ]] || [[ "$output" == *"Error"* ]]
  fi
}
