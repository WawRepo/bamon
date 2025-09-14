#!/usr/bin/env bats
# test/installation/test_user_installation.bats

load "../container/test_helpers.sh"

@test "User installation creates binary in ~/.local/bin" {
  install_bamon "user"
  [ -x "$HOME/.local/bin/bamon" ]
}

@test "User installation creates config directory" {
  install_bamon "user"
  [ -d "$HOME/.config/bamon" ]
}

@test "User installation creates default config file" {
  install_bamon "user"
  [ -f "$HOME/.config/bamon/config.yaml" ]
}

@test "User installation creates sample scripts" {
  install_bamon "user"
  [ -d "$HOME/.config/bamon/samples" ]
  [ -f "$HOME/.config/bamon/samples/health_check.sh" ]
  [ -f "$HOME/.config/bamon/samples/disk_usage.sh" ]
  [ -f "$HOME/.config/bamon/samples/github_status.sh" ]
}

@test "User installation makes sample scripts executable" {
  install_bamon "user"
  [ -x "$HOME/.config/bamon/samples/health_check.sh" ]
  [ -x "$HOME/.config/bamon/samples/disk_usage.sh" ]
  [ -x "$HOME/.config/bamon/samples/github_status.sh" ]
}

@test "User installation creates default scripts in config" {
  install_bamon "user"
  
  # Check that default scripts are configured
  run /usr/local/bin/yq e '.scripts[].name' "$HOME/.config/bamon/config.yaml"
  [ "$status" -eq 0 ]
  [[ "$output" == *"health_check"* ]]
  [[ "$output" == *"disk_usage"* ]]
  [[ "$output" == *"github_status"* ]]
}

@test "User installation bamon command works" {
  install_bamon "user"
  
  run run_bamon "user" --help
  [ "$status" -eq 0 ]
  # Check for any help output (BAMON might not be in the help text)
  [ -n "$output" ]
}
