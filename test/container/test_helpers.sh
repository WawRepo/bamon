#!/usr/bin/env bash
# test/container/test_helpers.sh

# Setup function to run before each test
setup() {
  # Create temporary test directory
  TEST_DIR="$(mktemp -d)"
  cd "$TEST_DIR"
  
  # Initialize test environment
  export BAMON_TEST_MODE=true
  export BAMON_CONFIG_DIR="$TEST_DIR/.config/bamon"
  mkdir -p "$BAMON_CONFIG_DIR"
  
  # Set up PATH for test user
  export PATH="/usr/local/bin:$PATH"
  
  # Ensure yq is in PATH
  if ! command -v yq >/dev/null 2>&1; then
    export PATH="/usr/local/bin:$PATH"
  fi
}

# Teardown function to run after each test
teardown() {
  # Stop any running daemon
  if [[ -f "$BAMON_CONFIG_DIR/bamon.pid" ]]; then
    PID=$(cat "$BAMON_CONFIG_DIR/bamon.pid")
    if kill -0 "$PID" 2>/dev/null; then
      kill "$PID" 2>/dev/null || true
    fi
  fi
  
  # Clean up test directory
  cd /
  rm -rf "$TEST_DIR"
}

# Helper to install bamon in test environment
install_bamon() {
  local mode=$1
  
  # Copy BAMON binary to appropriate location
  if [[ "$mode" == "user" ]]; then
    mkdir -p "$HOME/.local/bin"
    cp /app/bamon "$HOME/.local/bin/bamon"
    chmod +x "$HOME/.local/bin/bamon"
    # Create config directory
    mkdir -p "$HOME/.config/bamon"
    # Copy sample scripts
    mkdir -p "$HOME/.config/bamon/samples"
    cp /app/samples/*.sh "$HOME/.config/bamon/samples/"
    chmod +x "$HOME/.config/bamon/samples/"*.sh
    # Create default config (no need to copy install.sh)
    # Extract config from install script (simplified version)
    cat > "$HOME/.config/bamon/config.yaml" << 'EOF'
default_interval: 300
log_file: "/tmp/bamon.log"
pid_file: "/tmp/bamon.pid"
max_concurrent: 3
scripts:
  health_check:
    name: "health_check"
    command: "curl -s -o /dev/null -w \"%{http_code}\" https://httpbin.org/status/200"
    interval: 300
    enabled: true
  disk_usage:
    name: "disk_usage"
    command: "df -h / | awk 'NR==2 {print $5}' | sed 's/%//'"
    interval: 300
    enabled: true
  github_status:
    name: "github_status"
    command: "curl -s https://www.githubstatus.com/api/v2/status.json | jq -r '.status.indicator'"
    interval: 300
    enabled: true
EOF
  elif [[ "$mode" == "system" ]]; then
    sudo cp /app/bamon /usr/local/bin/bamon
    sudo chmod +x /usr/local/bin/bamon
    # Create config directory
    sudo mkdir -p /etc/bamon
    # Copy sample scripts
    sudo mkdir -p /etc/bamon/samples
    sudo cp /app/samples/*.sh /etc/bamon/samples/
    sudo chmod +x /etc/bamon/samples/*.sh
    # Create default config
    sudo tee /etc/bamon/config.yaml > /dev/null << 'EOF'
default_interval: 300
log_file: "/var/log/bamon.log"
pid_file: "/var/run/bamon.pid"
max_concurrent: 3
scripts:
  health_check:
    name: "health_check"
    command: "curl -s -o /dev/null -w \"%{http_code}\" https://httpbin.org/status/200"
    interval: 300
    enabled: true
  disk_usage:
    name: "disk_usage"
    command: "df -h / | awk 'NR==2 {print $5}' | sed 's/%//'"
    interval: 300
    enabled: true
  github_status:
    name: "github_status"
    command: "curl -s https://www.githubstatus.com/api/v2/status.json | jq -r '.status.indicator'"
    interval: 300
    enabled: true
EOF
  else
    # Dev mode - just copy binary to current directory
    cp /app/bamon ./bamon
    chmod +x ./bamon
    # Create config directory
    mkdir -p .config/bamon
    # Copy sample scripts
    mkdir -p .config/bamon/samples
    cp /app/samples/*.sh .config/bamon/samples/
    chmod +x .config/bamon/samples/*.sh
    # Create default config
    cat > .config/bamon/config.yaml << 'EOF'
default_interval: 300
log_file: "/tmp/bamon.log"
pid_file: "/tmp/bamon.pid"
max_concurrent: 3
scripts:
  health_check:
    name: "health_check"
    command: "curl -s -o /dev/null -w \"%{http_code}\" https://httpbin.org/status/200"
    interval: 300
    enabled: true
  disk_usage:
    name: "disk_usage"
    command: "df -h / | awk 'NR==2 {print $5}' | sed 's/%//'"
    interval: 300
    enabled: true
  github_status:
    name: "github_status"
    command: "curl -s https://www.githubstatus.com/api/v2/status.json | jq -r '.status.indicator'"
    interval: 300
    enabled: true
EOF
  fi
}

# Helper to verify bamon is installed correctly
verify_installation() {
  local mode=$1
  
  # Check binary exists and is executable
  if [[ "$mode" == "user" ]]; then
    test -x "$HOME/.local/bin/bamon"
  else
    test -x "/usr/local/bin/bamon"
  fi
  
  # Check configuration exists
  if [[ "$mode" == "user" ]]; then
    test -d "$HOME/.config/bamon"
  else
    test -d "/etc/bamon"
  fi
}

# Helper to run bamon command
run_bamon() {
  local mode=$1
  shift
  
  if [[ "$mode" == "user" ]]; then
    "$HOME/.local/bin/bamon" "$@"
  else
    "/usr/local/bin/bamon" "$@"
  fi
}

# Helper to wait for daemon to start
wait_for_daemon() {
  local timeout=10
  local count=0
  
  while [[ $count -lt $timeout ]]; do
    if [[ -f "$BAMON_CONFIG_DIR/bamon.pid" ]]; then
      local pid=$(cat "$BAMON_CONFIG_DIR/bamon.pid")
      if kill -0 "$pid" 2>/dev/null; then
        return 0
      fi
    fi
    sleep 1
    ((count++))
  done
  
  return 1
}

# Helper to stop daemon
stop_daemon() {
  if [[ -f "$BAMON_CONFIG_DIR/bamon.pid" ]]; then
    local pid=$(cat "$BAMON_CONFIG_DIR/bamon.pid")
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
      sleep 2
    fi
  fi
}
