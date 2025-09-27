#!/usr/bin/env bash

set -e

# Default values
REPO="WawRepo/bamon"
VERSION="latest"
MODE=""
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/bamon"
USER_CONFIG_DIR="$HOME/.config/bamon"
TEMP_DIR=""

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
    --version=*)
      VERSION="${1#*=}"
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
      echo "  --version=VERSION  Install specific version (default: latest)"
      echo "  --force            Override existing configuration (use with caution)"
      echo "  --help             Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0                                    # User installation (latest)"
      echo "  $0 --system                           # System installation (latest)"
      echo "  $0 --version=v0.1.0                  # Install specific version"
      echo "  $0 --prefix=/opt/bin --force         # Custom location with force override"
      echo ""
      echo "This script downloads BAMON from GitHub releases and installs it."
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

# Create temporary directory
TEMP_DIR=$(mktemp -d)
echo "📁 Using temporary directory: $TEMP_DIR"

# Cleanup function
cleanup() {
  if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
    echo "🧹 Cleaning up temporary directory..."
    rm -rf "$TEMP_DIR"
  fi
}
trap cleanup EXIT

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

echo "BAMON Installation Script (GitHub Release)"
echo "=========================================="
echo "Repository: $REPO"
echo "Version: $VERSION"
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

# Download release assets
echo "📥 Downloading BAMON release from GitHub..."

# Get the latest release info
if [[ "$VERSION" == "latest" ]]; then
  RELEASE_URL="https://api.github.com/repos/$REPO/releases/latest"
else
  RELEASE_URL="https://api.github.com/repos/$REPO/releases/tags/$VERSION"
fi

echo "🔍 Fetching release information..."
RELEASE_INFO=$(curl -s "$RELEASE_URL")

# Check if release exists
if echo "$RELEASE_INFO" | grep -q '"message": "Not Found"'; then
  echo "❌ Error: Release '$VERSION' not found"
  echo "Available releases: https://github.com/$REPO/releases"
  exit 1
fi

# Extract download URLs
BINARY_URL=$(echo "$RELEASE_INFO" | grep '"browser_download_url".*bamon"' | head -1 | sed 's/.*"browser_download_url": "\([^"]*\)".*/\1/')
SAMPLES_URL=$(echo "$RELEASE_INFO" | grep '"browser_download_url".*samples.tar.gz"' | head -1 | sed 's/.*"browser_download_url": "\([^"]*\)".*/\1/')
DOCS_URL=$(echo "$RELEASE_INFO" | grep '"browser_download_url".*docs.tar.gz"' | head -1 | sed 's/.*"browser_download_url": "\([^"]*\)".*/\1/')

if [[ -z "$BINARY_URL" ]]; then
  echo "❌ Error: Could not find BAMON binary in release"
  exit 1
fi

# Download binary
echo "📦 Downloading BAMON binary..."
curl -L -o "$TEMP_DIR/bamon" "$BINARY_URL"
chmod +x "$TEMP_DIR/bamon"

# Download samples if available
if [[ -n "$SAMPLES_URL" ]]; then
  echo "📝 Downloading sample scripts..."
  curl -L -o "$TEMP_DIR/samples.tar.gz" "$SAMPLES_URL"
  cd "$TEMP_DIR"
  tar -xzf samples.tar.gz
  cd - > /dev/null
fi

# Create installation directories
echo "📁 Creating directories..."
mkdir -p "$INSTALL_DIR"
if [[ "$PRESERVE_CONFIG" == "false" ]]; then
  mkdir -p "$CONFIG_DIR"
fi

# Install binary
echo "📦 Installing BAMON binary to $INSTALL_DIR/bamon..."
cp "$TEMP_DIR/bamon" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/bamon"

# Install sample scripts and configuration (only if not preserving)
if [[ "$PRESERVE_CONFIG" == "false" ]]; then
  if [[ -d "$TEMP_DIR/samples" ]]; then
    echo "📝 Installing sample scripts..."
    mkdir -p "$CONFIG_DIR/samples"
    cp -r "$TEMP_DIR/samples"/* "$CONFIG_DIR/samples/"
    chmod +x "$CONFIG_DIR/samples"/*.sh
  fi

  echo "🔧 Installing default config to $CONFIG_DIR/config.yaml..."
  cat > "$CONFIG_DIR/config.yaml" << 'CONFIG_EOF'
daemon:
  default_interval: 60
  log_file: "$CONFIG_DIR/bamon.log"
  pid_file: "$CONFIG_DIR/bamon.pid"
  max_concurrent: 10

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
