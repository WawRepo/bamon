# BAMON - Bash Daemon Monitor

A powerful and configurable bash daemon that monitors and executes bash scripts/code snippets at specified intervals, providing a comprehensive CLI interface for management.

## 🚀 Features

- **Script Monitoring**: Monitor and execute bash scripts at configurable intervals
- **CLI Management**: Simple command-line interface for managing monitored scripts
- **Health Checks**: Built-in support for HTTP health checks and system monitoring
- **Resource Management**: Configurable execution intervals and concurrent execution limits
- **Status Reporting**: Detailed status reporting with execution history and performance metrics
- **Sandboxing**: Secure script execution with resource limits and timeout protection
- **Configuration**: YAML-based configuration with validation and management commands
- **Logging**: Comprehensive logging with configurable levels and rotation

## 📦 Installation

### Quick Start (Recommended)

The easiest way to install BAMON is using the provided installation script:

```bash
# Clone the repository
git clone https://github.com/yourusername/bamon.git
cd bamon

# Run the installation script
chmod +x install.sh
./install.sh
```

This will:
- Install BAMON to `~/.local/bin/bamon` (user installation)
- Set up default configuration in `~/.config/bamon/`
- Install sample monitoring scripts
- Add BAMON to your PATH

### Installation Options

#### User Installation (Default)
```bash
./install.sh
# Installs to ~/.local/bin/bamon
```

#### System Installation
```bash
sudo ./install.sh --system
# Installs to /usr/local/bin/bamon
```

#### Custom Installation
```bash
./install.sh --prefix=/custom/path
# Installs to /custom/path/bamon
```

### Dependencies

BAMON requires the following runtime dependencies:

- **bash** 4.0+ (system default or Homebrew)
- **curl** (for HTTP health checks)
- **yq** (YAML processor)
- **timeout/gtimeout** (GNU coreutils)
- Standard Unix tools (awk, sed, grep, etc.)

#### Installing Dependencies

**macOS (with Homebrew):**
```bash
brew install curl yq coreutils
```

**Ubuntu/Debian:**
```bash
sudo apt install curl yq coreutils
```

**RHEL/CentOS/Fedora:**
```bash
sudo yum install curl yq coreutils
# or for newer systems
sudo dnf install curl yq coreutils
```

## 🛠️ Development Setup

For developers who want to build BAMON from source or contribute to the project:

### Prerequisites

- **Ruby** 2.7+ (for bashly)
- **bashly** gem (`gem install bashly`)
- **bash** 4.0+ (Homebrew version recommended)
- **Git** (for version control)

### Setup Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/bamon.git
   cd bamon
   ```

2. **Install Ruby and bashly:**
   
   **macOS with Homebrew:**
   ```bash
   brew install ruby
   export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
   export PATH="$(ruby -r rubygems -e "puts Gem.bindir"):$PATH"
   gem install bashly
   ```
   
   **Ubuntu/Debian:**
   ```bash
   sudo apt install ruby ruby-dev
   gem install bashly
   ```

3. **Generate the binary:**
   ```bash
   bashly generate
   ```

4. **Test the installation:**
   ```bash
   ./bamon --help
   ```

### Build Process

BAMON uses [Bashly](https://github.com/DannyBen/bashly) to generate the CLI framework. Bashly is a powerful bash CLI framework that helps create beautiful command-line tools with minimal effort. After making changes to the `src` directory:

1. **Regenerate the CLI:**
   ```bash
   bashly generate
   ```

2. **Test your changes:**
   ```bash
   ./bamon --help
   ```

For more information about Bashly, visit the [official repository](https://github.com/DannyBen/bashly) and [documentation](https://bashly.dannyb.co/).

## 🚀 Quick Start

### 1. Start the Daemon

```bash
# Start in background (daemon mode)
bamon start --daemon

# Start in foreground (for testing)
bamon start
```

### 2. Check Status

```bash
# View current status of all scripts
bamon status

# View only failed scripts
bamon status --failed-only

# Get JSON output
bamon status --json
```

#### Output Display

BAMON intelligently handles different types of script output:

- **Short Output**: Shows complete output in table view
- **Long Output**: Shows `(truncated - use --json)` in table view
- **Multiline Output**: Shows `(truncated - use --json)` in table view
- **JSON View**: Always shows complete output with proper formatting
  - Multiline output displayed as JSON arrays: `["line1", "line2", "line3"]`
  - Single-line output displayed as strings: `"output"`

### 3. Add Monitoring Scripts

```bash
# Add a simple health check
bamon add "health_check" \
  --command "curl -s -o /dev/null -w '%{http_code}' https://httpbin.org/status/200" \
  --interval 30 \
  --description "Check if httpbin.org is accessible"

# Add a disk usage monitor
bamon add "disk_usage" \
  --command "df -h / | awk 'NR==2 {print \$5}' | sed 's/%//' | awk '{if(\$1>80) exit 1; else exit 0}'" \
  --interval 300 \
  --description "Check if disk usage is under 80%"

# Add a process check
bamon add "nginx_check" \
  --command "pgrep nginx > /dev/null || exit 1" \
  --interval 60 \
  --description "Check if Nginx is running"
```

### 4. Manage Scripts

```bash
# List all scripts
bamon list

# Remove a script
bamon remove health_check

# Execute all scripts immediately
bamon now

# Execute a specific script
bamon now --name disk_usage
```

### 5. Stop the Daemon

```bash
# Stop gracefully
bamon stop

# Force stop
bamon stop --force
```

## ⚙️ Configuration

BAMON uses YAML configuration files. The default configuration is created at `~/.config/bamon/config.yaml`.

### Configuration Management

```bash
# View current configuration
bamon config show

# Edit configuration
bamon config edit

# Validate configuration
bamon config validate
```

### Example Configuration

```yaml
daemon:
  default_interval: 60
  log_file: "~/.config/bamon/bamon.log"
  pid_file: "~/.config/bamon/bamon.pid"
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
    description: "Check if httpbin.org is accessible"
  
  - name: "disk_usage"
    command: "df -h / | awk 'NR==2 {print $5}' | sed 's/%//' | awk '{if($1>80) exit 1; else exit 0}'"
    interval: 300
    enabled: true
    description: "Check if disk usage is under 80%"
```

## 📋 Command Reference

### Core Commands

| Command | Description | Example |
|---------|-------------|---------|
| `status` | Show current status of all scripts | `bamon status` |
| `add` | Add a new script to monitor | `bamon add "check" --command "echo test"` |
| `remove` | Remove a script from monitoring | `bamon remove check` |
| `list` | List all configured scripts | `bamon list` |
| `now` | Execute all scripts immediately | `bamon now` |

### Daemon Commands

| Command | Description | Example |
|---------|-------------|---------|
| `start` | Start the daemon process | `bamon start --daemon` |
| `stop` | Stop the daemon process | `bamon stop` |
| `restart` | Restart the daemon process | `bamon restart` |

### Configuration Commands

| Command | Description | Example |
|---------|-------------|---------|
| `config show` | Display current configuration | `bamon config show` |
| `config edit` | Edit configuration file | `bamon config edit` |
| `config validate` | Validate configuration | `bamon config validate` |

### Performance Commands

| Command | Description | Example |
|---------|-------------|---------|
| `performance` | Show performance metrics | `bamon performance` |

## 📊 Examples

### HTTP Health Checks

```bash
# Check if a website is accessible
bamon add "website_check" \
  --command "curl -s -o /dev/null -w '%{http_code}' https://example.com" \
  --interval 60 \
  --description "Check if example.com is accessible"

# Check API endpoint
bamon add "api_check" \
  --command "curl -s -H 'Accept: application/json' https://api.example.com/health | jq -e '.status == \"ok\"'" \
  --interval 30 \
  --description "Check API health endpoint"
```

### System Resource Monitoring

```bash
# Monitor disk usage
bamon add "disk_monitor" \
  --command "df -h / | awk 'NR==2 {print \$5}' | sed 's/%//' | awk '{if(\$1>90) exit 1; else exit 0}'" \
  --interval 300 \
  --description "Alert if disk usage exceeds 90%"

# Monitor memory usage
bamon add "memory_monitor" \
  --command "free -m | awk '/^Mem:/ {print \$3/\$2 * 100.0}' | awk '{if(\$1>85) exit 1; else exit 0}'" \
  --interval 300 \
  --description "Alert if memory usage exceeds 85%"

# Monitor CPU load
bamon add "cpu_monitor" \
  --command "uptime | awk '{print \$10}' | sed 's/,//' | awk '{if(\$1>2.0) exit 1; else exit 0}'" \
  --interval 60 \
  --description "Alert if 1-minute load average exceeds 2.0"
```

### Process Monitoring

```bash
# Check if a service is running
bamon add "nginx_check" \
  --command "pgrep nginx > /dev/null || exit 1" \
  --interval 60 \
  --description "Check if Nginx is running"

# Check database connection
bamon add "db_check" \
  --command "mysql -u root -e 'SELECT 1' > /dev/null 2>&1 || exit 1" \
  --interval 120 \
  --description "Check MySQL database connection"
```

### Multiline Output Examples

BAMON handles scripts that produce multiple lines of output:

```bash
# Add a script that outputs multiple lines
bamon add "system_info" \
  --command "echo 'System Information'; echo '=================='; hostname; date; uptime" \
  --interval 300 \
  --description "Display system information"

# Table view shows: (truncated - use --json)
bamon status

# JSON view shows complete multiline output as array
bamon status --json
# Output: ["System Information", "==================", "hostname", "date", "uptime"]
```

**Output Handling:**
- **Table View**: Clean display with truncation hints for long/multiline content
- **JSON View**: Complete output preserved with proper formatting
- **Data Storage**: Uses JSON escaping (no base64 encoding) for cleaner data

## 🔧 Troubleshooting

### Common Issues

#### Daemon fails to start
```bash
# Check if another instance is running
bamon status

# Check logs for errors
tail -f ~/.config/bamon/bamon.log

# Verify permissions
ls -la ~/.config/bamon/
```

#### Scripts not executing
```bash
# Check if scripts are enabled
bamon list

# Test script manually
bash -c "your_script_command"

# Check execution logs
bamon status --verbose
```

#### Installation Issues
```bash
# Check dependencies
curl --version
yq --version
bash --version

# Verify installation
which bamon
bamon --version
```

### Debug Mode

```bash
# Run with verbose logging
BAMON_LOG_LEVEL=DEBUG bamon start

# Check configuration
bamon config validate --verbose
```

## 🔒 Security Considerations

- **Sandboxing**: All scripts run in a sandboxed environment with resource limits
- **Permissions**: Scripts run with the permissions of the user who started the daemon
- **Sensitive Data**: Avoid including sensitive information directly in script commands
- **Credential Storage**: Use environment variables or secure credential storage for sensitive data
- **User Isolation**: Consider running BAMON with a dedicated user with minimal permissions

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `bats test/*.bats`
5. Submit a pull request

### Testing

```bash
# Run all tests
bats test/*.bats

# Run specific test suite
bats test/commands/

# Run with verbose output
bats --tap test/*.bats
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Bashly](https://github.com/DannyBen/bashly) - A powerful bash CLI framework for creating beautiful command-line tools
- Inspired by modern monitoring tools and best practices
- Thanks to all contributors and users

---

**Need help?** Check out our [FAQ](docs/FAQ.md) or open an [issue](https://github.com/yourusername/bamon/issues).
