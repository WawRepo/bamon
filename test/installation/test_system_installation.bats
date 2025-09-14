#!/usr/bin/env bats
# test/installation/test_system_installation.bats

load "../container/test_helpers.sh"

@test "System installation creates binary in /usr/local/bin" {
  install_bamon "system"
  [ -x "/usr/local/bin/bamon" ]
}

@test "System installation creates config directory" {
  install_bamon "system"
  [ -d "/etc/bamon" ]
}

@test "System installation creates default config file" {
  install_bamon "system"
  [ -f "/etc/bamon/config.yaml" ]
}

@test "System installation creates sample scripts" {
  install_bamon "system"
  [ -d "/etc/bamon/samples" ]
  [ -f "/etc/bamon/samples/health_check.sh" ]
  [ -f "/etc/bamon/samples/disk_usage.sh" ]
  [ -f "/etc/bamon/samples/github_status.sh" ]
}

@test "System installation makes sample scripts executable" {
  install_bamon "system"
  [ -x "/etc/bamon/samples/health_check.sh" ]
  [ -x "/etc/bamon/samples/disk_usage.sh" ]
  [ -x "/etc/bamon/samples/github_status.sh" ]
}

@test "System installation bamon command works" {
  install_bamon "system"
  
  run run_bamon "system" --help
  [ "$status" -eq 0 ]
  # Check for any help output (BAMON might not be in the help text)
  [ -n "$output" ]
}
