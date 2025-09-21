#!/usr/bin/env bash
# Test config reset command

load "../container/test_helpers.sh"

@test "Config reset creates default configuration" {
  # Install BAMON
  install_bamon "user"
  
  # Remove existing config if it exists
  rm -f "$BAMON_CONFIG_DIR/config.yaml"
  
  # Run config reset with force flag
  BAMON_CONFIG_FILE="$BAMON_CONFIG_DIR/config.yaml" run run_bamon "user" config reset --force
  
  # Should succeed
  [ "$status" -eq 0 ]
  
  # Should create config file
  [ -f "$BAMON_CONFIG_DIR/config.yaml" ]
  
  # Should contain default sections
  grep -q "daemon:" "$BAMON_CONFIG_DIR/config.yaml"
  grep -q "sandbox:" "$BAMON_CONFIG_DIR/config.yaml"
  grep -q "performance:" "$BAMON_CONFIG_DIR/config.yaml"
  grep -q "scripts:" "$BAMON_CONFIG_DIR/config.yaml"
  
  # Should contain default scripts
  grep -q "health_check" "$BAMON_CONFIG_DIR/config.yaml"
  grep -q "disk_check" "$BAMON_CONFIG_DIR/config.yaml"
}

@test "Config reset always creates backup file when config exists" {
  # Install BAMON
  install_bamon "user"
  
  # Create a custom config file
  mkdir -p "$BAMON_CONFIG_DIR"
  cat > "$BAMON_CONFIG_DIR/config.yaml" << EOF
daemon:
  default_interval: 120
  log_file: "/tmp/custom.log"
  pid_file: "/tmp/custom.pid"
  max_concurrent: 5

sandbox:
  timeout: 60
  max_cpu_time: 120
  max_file_size: 20480
  max_virtual_memory: 204800

performance:
  enable_monitoring: false
  load_threshold: 0.9
  cache_ttl: 60
  optimize_scheduling: false

scripts:
  - name: "custom_script"
    command: "echo custom"
    interval: 60
    description: "Custom test script"
    enabled: true
EOF
  
  # Run config reset (backup is automatic now)
  BAMON_CONFIG_FILE="$BAMON_CONFIG_DIR/config.yaml" run run_bamon "user" config reset --force
  
  # Should succeed
  [ "$status" -eq 0 ]
  
  # Should create backup file
  local backup_files=("$BAMON_CONFIG_DIR/config.yaml.backup."*)
  [ -f "${backup_files[0]}" ]
  
  # Backup should contain original content
  grep -q "custom_script" "${backup_files[0]}"
  grep -q "default_interval: 120" "${backup_files[0]}"
  
  # New config should contain default content
  grep -q "health_check" "$BAMON_CONFIG_DIR/config.yaml"
  grep -q "default_interval: 60" "$BAMON_CONFIG_DIR/config.yaml"
}

@test "Config reset without force prompts for confirmation" {
  # Install BAMON
  install_bamon "user"
  
  # Create a config file
  mkdir -p "$BAMON_CONFIG_DIR"
  echo "test: config" > "$BAMON_CONFIG_DIR/config.yaml"
  
  # Run config reset without force (should prompt)
  BAMON_CONFIG_FILE="$BAMON_CONFIG_DIR/config.yaml" run run_bamon "user" config reset <<< "n"
  
  # Should succeed but not reset (user said no)
  [ "$status" -eq 0 ]
  
  # Should contain original content
  grep -q "test: config" "$BAMON_CONFIG_DIR/config.yaml"
}

@test "Config reset with force skips confirmation" {
  # Install BAMON
  install_bamon "user"
  
  # Create a config file
  mkdir -p "$BAMON_CONFIG_DIR"
  echo "test: config" > "$BAMON_CONFIG_DIR/config.yaml"
  
  # Run config reset with force flag
  BAMON_CONFIG_FILE="$BAMON_CONFIG_DIR/config.yaml" run run_bamon "user" config reset --force
  
  # Should succeed
  [ "$status" -eq 0 ]
  
  # Should contain default content
  grep -q "daemon:" "$BAMON_CONFIG_DIR/config.yaml"
  grep -q "health_check" "$BAMON_CONFIG_DIR/config.yaml"
}

@test "Config reset when no config exists" {
  # Install BAMON
  install_bamon "user"
  
  # Remove config file
  rm -f "$BAMON_CONFIG_DIR/config.yaml"
  
  # Run config reset
  BAMON_CONFIG_FILE="$BAMON_CONFIG_DIR/config.yaml" run run_bamon "user" config reset --force
  
  # Should succeed
  [ "$status" -eq 0 ]
  
  # Should say creating new default configuration
  echo "$output" | grep -q "Creating new default configuration"
}

@test "Config reset creates necessary directories" {
  # Install BAMON
  install_bamon "user"
  
  # Remove config directory
  rm -rf "$BAMON_CONFIG_DIR"
  
  # Run config reset
  BAMON_CONFIG_FILE="$BAMON_CONFIG_DIR/config.yaml" run run_bamon "user" config reset --force
  
  # Should succeed
  [ "$status" -eq 0 ]
  
  # Should create config directory
  [ -d "$BAMON_CONFIG_DIR" ]
  
  # Should create config file
  [ -f "$BAMON_CONFIG_DIR/config.yaml" ]
}

@test "Config reset validates new configuration" {
  # Install BAMON
  install_bamon "user"
  
  # Remove existing config
  rm -f "$BAMON_CONFIG_DIR/config.yaml"
  
  # Run config reset
  BAMON_CONFIG_FILE="$BAMON_CONFIG_DIR/config.yaml" run run_bamon "user" config reset --force
  
  # Should succeed
  [ "$status" -eq 0 ]
  
  # Should create valid config
  BAMON_CONFIG_FILE="$BAMON_CONFIG_DIR/config.yaml" run run_bamon "user" config validate
  [ "$status" -eq 0 ]
  
  # Should contain valid YAML
  grep -q "daemon:" "$BAMON_CONFIG_DIR/config.yaml"
  grep -q "sandbox:" "$BAMON_CONFIG_DIR/config.yaml"
  grep -q "performance:" "$BAMON_CONFIG_DIR/config.yaml"
  grep -q "scripts:" "$BAMON_CONFIG_DIR/config.yaml"
}
