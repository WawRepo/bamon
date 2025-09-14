#!/usr/bin/env bats
# test/commands/test_remove_command.bats

load "../container/test_helpers.sh"

setup() {
  # Common setup
  install_bamon "user"
}

@test "Remove command removes existing script" {
  # Add a script first
  run run_bamon "user" add test_script --command "echo 'test'" --interval 60
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== ADD COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    if [ -f "$HOME/.config/bamon/config.yaml" ]; then
      echo "Config file contents:"
      cat "$HOME/.config/bamon/config.yaml"
    fi
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  
  # Verify it exists
  run yq e '.scripts[] | select(.name == "test_script")' "$HOME/.config/bamon/config.yaml"
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== SCRIPT NOT FOUND AFTER ADD ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    if [ -f "$HOME/.config/bamon/config.yaml" ]; then
      echo "Config file contents:"
      cat "$HOME/.config/bamon/config.yaml"
    fi
    echo "=================================="
  fi
  
  [ "$status" -eq 0 ]
  [ -n "$output" ]
  
  # Remove it
  run run_bamon "user" remove test_script --force
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== REMOVE COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    if [ -f "$HOME/.config/bamon/config.yaml" ]; then
      echo "Config file contents:"
      cat "$HOME/.config/bamon/config.yaml"
    fi
    echo "============================="
  fi
  
  [ "$status" -eq 0 ]
  
  # Verify it's gone
  run yq e '.scripts[] | select(.name == "test_script")' "$HOME/.config/bamon/config.yaml"
  
  # Debug output on failure
  if [ -n "$output" ]; then
    echo "=== SCRIPT STILL EXISTS AFTER REMOVE ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Expected script to be removed but it still exists"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    if [ -f "$HOME/.config/bamon/config.yaml" ]; then
      echo "Config file contents:"
      cat "$HOME/.config/bamon/config.yaml"
    fi
    echo "======================================="
  fi
  
  [ -z "$output" ]
}

@test "Remove command fails for non-existent script" {
  run run_bamon "user" remove non_existent_script --force
  
  # Debug output on failure
  if [ "$status" -eq 0 ]; then
    echo "=== REMOVE NON-EXISTENT SCRIPT SHOULD HAVE FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Expected error for non-existent script but got success"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    if [ -f "$HOME/.config/bamon/config.yaml" ]; then
      echo "Config file contents:"
      cat "$HOME/.config/bamon/config.yaml"
    fi
    echo "===================================================="
  fi
  
  [ "$status" -ne 0 ]
}

@test "Remove command preserves other scripts" {
  # Add two scripts
  run run_bamon "user" add test_script1 --command "echo 'test1'" --interval 60
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== ADD FIRST SCRIPT FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    echo "=============================="
  fi
  
  [ "$status" -eq 0 ]
  
  run run_bamon "user" add test_script2 --command "echo 'test2'" --interval 60
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== ADD SECOND SCRIPT FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    echo "==============================="
  fi
  
  [ "$status" -eq 0 ]
  
  # Remove one
  run run_bamon "user" remove test_script1 --force
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== REMOVE FIRST SCRIPT FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    echo "================================="
  fi
  
  [ "$status" -eq 0 ]
  
  # Verify the other still exists
  run yq e '.scripts[] | select(.name == "test_script2")' "$HOME/.config/bamon/config.yaml"
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== SECOND SCRIPT NOT FOUND AFTER REMOVE ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Expected test_script2 to still exist but it's missing"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    if [ -f "$HOME/.config/bamon/config.yaml" ]; then
      echo "Config file contents:"
      cat "$HOME/.config/bamon/config.yaml"
    fi
    echo "============================================="
  fi
  
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}
