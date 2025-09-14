#!/usr/bin/env bats
# test/commands/test_add_command.bats

load "../container/test_helpers.sh"

setup() {
  # Common setup
  install_bamon "user"
}

@test "Add command creates new script entry" {
  run run_bamon "user" add test_script --command "echo 'test'" --interval 60
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== ADD COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "STDERR: (stderr is captured in output)"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    if [ -f "$HOME/.config/bamon/config.yaml" ]; then
      echo "Config file contents:"
      cat "$HOME/.config/bamon/config.yaml"
    fi
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  
  # Verify script was added to config
  run yq e '.scripts[] | select(.name == "test_script")' "$HOME/.config/bamon/config.yaml"
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "Add command with invalid parameters fails" {
  run run_bamon "user" add test_script --command "" --interval 60
  
  # Debug output on failure
  if [ "$status" -eq 0 ]; then
    echo "=== ADD WITH EMPTY COMMAND SHOULD HAVE FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Expected error for empty command but got success"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    if [ -f "$HOME/.config/bamon/config.yaml" ]; then
      echo "Config file contents:"
      cat "$HOME/.config/bamon/config.yaml"
    fi
    echo "==============================================="
  fi
  
  [ "$status" -ne 0 ]
}

@test "Add command with duplicate name fails" {
  # Add first script
  run run_bamon "user" add test_script --command "echo 'test1'" --interval 60
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== FIRST ADD COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    echo "================================"
  fi
  
  [ "$status" -eq 0 ]
  
  # Try to add duplicate
  run run_bamon "user" add test_script --command "echo 'test2'" --interval 60
  
  # Debug output on failure
  if [ "$status" -eq 0 ]; then
    echo "=== DUPLICATE ADD SHOULD HAVE FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Expected duplicate name error but got success"
    echo "=========================================="
  fi
  
  [ "$status" -ne 0 ]
}

@test "Add command enables script by default" {
  run run_bamon "user" add test_script --command "echo 'test'" --interval 60
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== ADD COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  
  # Check that script is enabled
  run yq e '.scripts[] | select(.name == "test_script") | .enabled' "$HOME/.config/bamon/config.yaml"
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== YQ QUERY FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    if [ -f "$HOME/.config/bamon/config.yaml" ]; then
      echo "Config file contents:"
      cat "$HOME/.config/bamon/config.yaml"
    fi
    echo "======================"
  fi
  
  [ "$status" -eq 0 ]
  [ "$output" = "true" ]
}
