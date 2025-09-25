# Installation

BAMON can be installed in several ways depending on your needs and environment.

## Quick Install (Recommended)

The easiest way to install BAMON is using our installation script:

```bash
# Download and install from latest release
curl -sSL https://github.com/WawRepo/bamon/releases/latest/download/install-repo.sh | bash
```

This will:
- Download the latest BAMON binary
- Install to `~/.local/bin` (user installation)
- Set up default configuration and sample scripts
- Add BAMON to your PATH

## Installation Options

### User Installation (Default)

```bash
# Install to user directory
curl -sSL https://github.com/WawRepo/bamon/releases/latest/download/install-repo.sh | bash
```

**Installation location**: `~/.local/bin/bamon`
**Configuration**: `~/.config/bamon/config.yaml`
**Logs**: `~/.local/share/bamon/logs/bamon.log`

### System Installation

```bash
# Install system-wide (requires sudo)
curl -sSL https://github.com/WawRepo/bamon/releases/latest/download/install-repo.sh | bash -s -- --system
```

**Installation location**: `/usr/local/bin/bamon`
**Configuration**: `/etc/bamon/config.yaml`
**Logs**: `/var/log/bamon/bamon.log`

### Custom Installation

```bash
# Install to custom directory
curl -sSL https://github.com/WawRepo/bamon/releases/latest/download/install-repo.sh | bash -s -- --prefix=/opt/bamon
```

## Prerequisites

### Required Dependencies

BAMON requires the following tools to be installed:

- **bash** 4.2+ (for script execution)
- **curl** (for health checks and downloads)
- **yq** (for YAML configuration processing)
- **timeout** (for script execution timeouts)

### Installing Dependencies

#### macOS (using Homebrew)

```bash
brew install bash curl yq coreutils
```

#### Ubuntu/Debian

```bash
sudo apt update
sudo apt install curl yq coreutils
```

#### RHEL/CentOS/Fedora

```bash
sudo yum install curl yq coreutils
# or for newer versions:
sudo dnf install curl yq coreutils
```

## Manual Installation

If you prefer to install manually:

### 1. Download Binary

```bash
# Download latest release
wget https://github.com/WawRepo/bamon/releases/latest/download/bamon
chmod +x bamon
```

### 2. Install Binary

```bash
# User installation
mkdir -p ~/.local/bin
mv bamon ~/.local/bin/
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# System installation
sudo mv bamon /usr/local/bin/
```

### 3. Create Configuration

```bash
# User configuration
mkdir -p ~/.config/bamon
cat > ~/.config/bamon/config.yaml << 'EOF'
daemon:
  default_interval: 60
  log_file: "~/.local/share/bamon/logs/bamon.log"
  pid_file: "~/.local/share/bamon/bamon.pid"
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

scripts: []
EOF
```

## Development Installation

For development and testing:

```bash
# Clone repository
git clone https://github.com/WawRepo/bamon.git
cd bamon

# Install development dependencies
brew install bashly yq  # macOS
# or
sudo apt install bashly yq  # Ubuntu

# Generate binary
bashly generate

# Test installation
./bamon --version
```

## Verification

After installation, verify BAMON is working:

```bash
# Check version
bamon --version

# Check configuration
bamon config show

# Test basic functionality
bamon status
```

## Shell Completions

Enable auto-completion for better command experience:

```bash
# Enable for current session
eval "$(bamon completions)"

# Make permanent (add to your shell config)
echo 'eval "$(bamon completions)"' >> ~/.bashrc  # Bash
echo 'eval "$(bamon completions)"' >> ~/.zshrc   # Zsh
```

## Troubleshooting

### Common Issues

**Command not found**: Ensure BAMON is in your PATH
```bash
echo $PATH | grep -q "$HOME/.local/bin" || export PATH="$HOME/.local/bin:$PATH"
```

**Permission denied**: Check file permissions
```bash
ls -la ~/.local/bin/bamon
chmod +x ~/.local/bin/bamon
```

**Missing dependencies**: Install required tools
```bash
# Check for required tools
command -v curl yq timeout bash
```

### Getting Help

If you encounter issues:

1. Check the [Troubleshooting Guide](https://wawrepo.github.io/bamon/troubleshooting/)
2. Review the [Configuration Guide](https://wawrepo.github.io/bamon/configuration/)
3. Open an issue on [GitHub](https://github.com/WawRepo/bamon/issues)
