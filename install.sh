#!/usr/bin/env bash

set -e

# Installation modes
MODE=""
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/bamon"
USER_CONFIG_DIR="$HOME/.config/bamon"

# Parse command line arguments
FORCE_OVERRIDE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --user)
      MODE="user"
      INSTALL_DIR="$HOME/.local/bin"
      CONFIG_DIR="$USER_CONFIG_DIR"
      shift
      ;;
    --system)
      MODE="system"
      shift
      ;;
    --prefix=*)
      INSTALL_DIR="${1#*=}"
      shift
      ;;
    --config-dir=*)
      CONFIG_DIR="${1#*=}"
      shift
      ;;
    --force)
      FORCE_OVERRIDE=true
      shift
      ;;
    --help)
      echo "Usage: $0 [--user|--system] [options]"
      echo ""
      echo "Modes:"
      echo "  --user     User installation (default)"
      echo "  --system   System-wide installation (requires root)"
      echo ""
      echo "Options:"
      echo "  --prefix=DIR       Install binary to DIR"
      echo "  --config-dir=DIR   Install config to DIR"
      echo "  --force            Override existing configuration (use with caution)"
      echo "  --help             Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0                    # User installation"
      echo "  $0 --system           # System installation (requires sudo)"
      echo "  $0 --prefix=/opt/bin  # Custom installation directory"
      echo "  $0 --force            # Override existing configuration"
      echo ""
      echo "Note: This script assumes BAMON files are in the current directory."
      echo "For installation from GitHub releases, use install-repo.sh instead."
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Default to user mode if not specified
if [[ -z "$MODE" ]]; then
  MODE="user"
  INSTALL_DIR="$HOME/.local/bin"
  CONFIG_DIR="$USER_CONFIG_DIR"
fi

# Check for existing configuration
PRESERVE_CONFIG=false
if [[ -f "$CONFIG_DIR/config.yaml" ]]; then
  if [[ "$FORCE_OVERRIDE" == "true" ]]; then
    echo "⚠️  Force override enabled - existing configuration will be replaced"
    PRESERVE_CONFIG=false
  else
    echo "ℹ️  Existing BAMON configuration detected at $CONFIG_DIR/config.yaml"
    echo "ℹ️  Preserving your current configuration and scripts"
    PRESERVE_CONFIG=true
  fi
else
  PRESERVE_CONFIG=false
fi

echo "BAMON Installation Script"
echo "========================="
echo "Mode: $MODE"
echo "Install directory: $INSTALL_DIR"
echo "Config directory: $CONFIG_DIR"
if [[ "$PRESERVE_CONFIG" == "true" ]]; then
  echo "Configuration: PRESERVING existing config"
else
  echo "Configuration: Setting up new config"
fi
echo ""

# Check system requirements
if [[ "$MODE" == "system" && "$(id -u)" -ne 0 ]]; then
  echo "Error: System installation requires root privileges"
  echo "Run with sudo or use --user for user installation"
  exit 1
fi

# Check runtime dependencies
echo "Checking runtime dependencies..."

# Check bash version
if ! bash --version | grep -q "version 4"; then
  echo "Warning: Bash 4.0+ recommended. Current version:"
  bash --version | head -1
fi

# Check for required tools
MISSING_DEPS=()

if ! command -v curl &>/dev/null; then
  MISSING_DEPS+=("curl")
fi

if ! command -v yq &>/dev/null; then
  MISSING_DEPS+=("yq")
fi

# Check for timeout command (gtimeout on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
  if ! command -v gtimeout &>/dev/null; then
    MISSING_DEPS+=("coreutils (for gtimeout)")
  fi
else
  if ! command -v timeout &>/dev/null; then
    MISSING_DEPS+=("timeout")
  fi
fi

if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
  echo "Missing dependencies: ${MISSING_DEPS[*]}"
  echo "Install with:"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "  brew install curl yq coreutils"
  else
    echo "  sudo apt install curl yq coreutils (Ubuntu/Debian)"
    echo "  sudo yum install curl yq coreutils (RHEL/CentOS)"
  fi
  exit 1
fi

# Create installation directories
echo "Creating directories..."
mkdir -p "$INSTALL_DIR"
if [[ "$PRESERVE_CONFIG" == "false" ]]; then
  mkdir -p "$CONFIG_DIR"
fi

# Install binary (copy from current directory) - ALWAYS update binary
echo "📦 Installing BAMON binary to $INSTALL_DIR/bamon..."
if [[ -f "./bamon" ]]; then
  cp "./bamon" "$INSTALL_DIR/"
  chmod +x "$INSTALL_DIR/bamon"
else
  echo "❌ Error: BAMON binary not found in current directory"
  echo "Make sure you're running this script from the BAMON repository root"
  exit 1
fi

# Install sample scripts and configuration (only if not preserving)
if [[ "$PRESERVE_CONFIG" == "false" ]]; then
  echo "📝 Installing sample scripts..."
  mkdir -p "$CONFIG_DIR/samples"
  if [[ -f "samples/health_check.sh" ]]; then
    cp "samples/health_check.sh" "$CONFIG_DIR/samples/"
    chmod +x "$CONFIG_DIR/samples/health_check.sh"
  fi
  if [[ -f "samples/disk_usage.sh" ]]; then
    cp "samples/disk_usage.sh" "$CONFIG_DIR/samples/"
    chmod +x "$CONFIG_DIR/samples/disk_usage.sh"
  fi
  if [[ -f "samples/github_status.sh" ]]; then
    cp "samples/github_status.sh" "$CONFIG_DIR/samples/"
    chmod +x "$CONFIG_DIR/samples/github_status.sh"
  fi

  echo "🔧 Installing default config to $CONFIG_DIR/config.yaml..."
  cat > "$CONFIG_DIR/config.yaml" << 'CONFIG_EOF'
daemon:
  default_interval: 60
  log_file: "$CONFIG_DIR/bamon.log"
  pid_file: "$CONFIG_DIR/bamon.pid"

sandbox:
  timeout: 30
  max_cpu_time: 60
  max_file_size: 10240
  max_virtual_memory: 102400

performance:
  enable_monitoring: true
  load_threshold: 0.8
  optimize_scheduling: true

scripts:
  - name: "health_check"
    command: "curl -s -o /dev/null -w '%{http_code}' https://httpbin.org/status/200"
    interval: 30
    enabled: true
  - name: "disk_usage"
    command: "df -h / | awk 'NR==2 {print \$5}' | sed 's/%//'"
    interval: 300
    enabled: true
  - name: "github_status"
    command: "curl -s https://www.githubstatus.com/api/v2/status.json | jq -r '.status.indicator' | grep -q 'none' && echo 'Github ok' || echo 'Github not ok'"
    interval: 30
    enabled: true
  - name: "sample_health_check"
    command: "$CONFIG_DIR/samples/health_check.sh"
    interval: 60
    enabled: false
  - name: "sample_disk_usage"
    command: "$CONFIG_DIR/samples/disk_usage.sh"
    interval: 300
    enabled: false
  - name: "sample_github_status"
    command: "$CONFIG_DIR/samples/github_status.sh"
    interval: 30
    enabled: false
CONFIG_EOF
else
  echo "🔒 Skipping configuration setup to preserve existing settings"
fi

# Add to PATH if user installation
if [[ "$MODE" == "user" ]]; then
  if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo "Adding $INSTALL_DIR to PATH..."
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.bashrc"
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.zshrc"
    echo "Please restart your shell or run: source ~/.bashrc"
  fi
fi

echo ""
echo "✅ Installation complete!"
echo ""

if [[ "$PRESERVE_CONFIG" == "true" ]]; then
  echo "🔒 Configuration preserved - your existing settings remain unchanged"
  echo "📦 BAMON binary has been updated successfully"
  echo ""
  echo "Quick Start:"
  echo "1. Check status: bamon status"
  echo "2. Start daemon: bamon start --daemon"
  echo "3. View logs: tail -f ~/.local/share/bamon/logs/bamon.log"
  echo ""
  echo "Your existing configuration and scripts are preserved."
  echo ""
  echo "🔧 Shell Completions:"
  echo "Enable auto-completion for better command experience:"
  echo "  eval \"\$(bamon completions)\""
  echo ""
  echo "To make completions permanent, add to your shell config:"
  echo "  # For Bash: echo 'eval \"\$(bamon completions)\"' >> ~/.bashrc"
  echo "  # For Zsh:  echo 'eval \"\$(bamon completions)\"' >> ~/.zshrc"
  echo ""
  echo "Run 'bamon --help' for more commands"
else
  echo "Quick Start:"
  echo "1. Check status: bamon status"
  echo "2. Start daemon: bamon start --daemon"
  echo "3. View logs: tail -f ~/.local/share/bamon/logs/bamon.log"
  echo ""
  echo "Sample Scripts:"
  echo "- health_check: HTTP health check (enabled by default)"
  echo "- disk_usage: Disk usage monitor (enabled by default)"
  echo "- github_status: GitHub status check (enabled by default)"
  echo "- sample_health_check: Advanced health check script (disabled)"
  echo "- sample_disk_usage: Advanced disk usage script (disabled)"
  echo "- sample_github_status: Advanced GitHub status script (disabled)"
  echo ""
  echo "Enable sample scripts:"
  echo "  bamon add sample_health_check '$CONFIG_DIR/samples/health_check.sh' --interval 60"
  echo "  bamon add sample_disk_usage '$CONFIG_DIR/samples/disk_usage.sh' --interval 300"
  echo "  bamon add sample_github_status '$CONFIG_DIR/samples/github_status.sh' --interval 30"
  echo ""
  echo "🔧 Shell Completions:"
  echo "Enable auto-completion for better command experience:"
  echo "  eval \"\$(bamon completions)\""
  echo ""
  echo "To make completions permanent, add to your shell config:"
  echo "  # For Bash: echo 'eval \"\$(bamon completions)\"' >> ~/.bashrc"
  echo "  # For Zsh:  echo 'eval \"\$(bamon completions)\"' >> ~/.zshrc"
  echo ""
  echo "Run 'bamon --help' for more commands"
fi
