#!/usr/bin/env bats
# test/commands/test_add_command.bats

load "../container/test_helpers.sh"

setup() {
  # Common setup
  install_bamon "user"
}

@test "Add command creates new script entry" {
  run run_bamon "user" add test_script --command "echo 'test'" --interval 60
  [ "$status" -eq 0 ]
  
  # Verify script was added to config
  run yq e '.scripts[] | select(.name == "test_script")' "$HOME/.config/bamon/config.yaml"
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "Add command with invalid parameters fails" {
  run run_bamon "user" add test_script --command "" --interval 60
  [ "$status" -ne 0 ]
}

@test "Add command with duplicate name fails" {
  # Add first script
  run run_bamon "user" add test_script --command "echo 'test1'" --interval 60
  [ "$status" -eq 0 ]
  
  # Try to add duplicate
  run run_bamon "user" add test_script --command "echo 'test2'" --interval 60
  [ "$status" -ne 0 ]
}

@test "Add command enables script by default" {
  run run_bamon "user" add test_script --command "echo 'test'" --interval 60
  [ "$status" -eq 0 ]
  
  # Check that script is enabled
  run yq e '.scripts[] | select(.name == "test_script") | .enabled' "$HOME/.config/bamon/config.yaml"
  [ "$status" -eq 0 ]
  [ "$output" = "true" ]
}
