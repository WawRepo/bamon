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

#### Option 1: Install from Latest Release (Easiest)

Install BAMON directly from the latest GitHub release:

```bash
# Download and install from latest release
curl -sSL https://github.com/WawRepo/bamon/releases/latest/download/install-repo.sh | bash
```

This will:
- Download the latest stable release
- Install BAMON to `~/.local/bin/bamon` (user installation)
- Set up default configuration in `~/.config/bamon/`
- Install sample monitoring scripts to `~/.config/bamon/samples/`
- Add BAMON to your PATH
- Create execution history file for performance tracking

#### Option 2: Install from Source

Clone the repository and install from source:

```bash
# Clone the repository
git clone https://github.com/WawRepo/bamon.git
cd bamon

# Run the installation script
chmod +x install.sh
./install.sh
```

This will:
- Install BAMON to `~/.local/bin/bamon` (user installation)
- Set up default configuration in `~/.config/bamon/`
- Install sample monitoring scripts to `~/.config/bamon/samples/`
- Add BAMON to your PATH
- Create execution history file for performance tracking

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
## 🔄 CI/CD and Release Automation

BAMON uses GitHub Actions for continuous integration and automated release management.

### Continuous Integration

- **Automatic Testing**: Every commit to `main` branch triggers comprehensive tests
- **Container Testing**: Full test suite runs in Ubuntu container environment
- **Dependency Validation**: Verifies all required dependencies are available
- **Binary Generation**: Tests bashly binary generation process
- **Cross-Platform**: Ensures compatibility across different environments

### Release Automation

- **Automated Versioning**: Patch versions are automatically incremented (e.g., v0.1.0 → v0.1.1)
- **Version Detection**: Reads highest git tag from main branch
- **Asset Packaging**: Creates complete release packages with all necessary files
- **GitHub Releases**: Automatically creates releases with proper tagging
- **Manual Triggers**: Release workflow can be triggered manually with version bump options

### Release Process

1. **Version Detection**: Finds highest existing tag (e.g., `v0.1.0`)
2. **Version Bump**: Increments patch version (e.g., `v0.1.0` → `v0.1.1`)
3. **Binary Update**: Updates `src/bashly.yml` and regenerates binary
4. **Asset Creation**: Packages all release files (binary, docs, samples, tests)
5. **Git Tagging**: Creates and pushes new version tag
6. **GitHub Release**: Creates release with all assets and documentation

### Release Assets

Each release includes:
- `bamon` - Main executable binary
- `install.sh` - Installation script
- `README.md` - Complete documentation
- `docs/` - Documentation directory
- `samples/` - Example monitoring scripts
- `test/` - Test suite for validation
- `config.yaml` - Default configuration template

### Status Badges

[![CI](https://github.com/WawRepo/bamon/workflows/Continuous%20Integration/badge.svg)](https://github.com/WawRepo/bamon/actions)
[![Release](https://github.com/WawRepo/bamon/workflows/Release/badge.svg)](https://github.com/WawRepo/bamon/actions)

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
   git clone https://github.com/WawRepo/bamon.git
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

## 🔧 Shell Completions

BAMON includes bash completions for all commands and options. To enable auto-completion:

### Enable Completions (Temporary)
```bash
# Enable for current session
eval "$(bamon completions)"
```

### Enable Completions (Permanent)

**For Bash:**
```bash
# Add to ~/.bashrc
echo 'eval "$(bamon completions)"' >> ~/.bashrc
source ~/.bashrc
```

**For Zsh:**
```bash
# Add to ~/.zshrc
echo 'eval "$(bamon completions)"' >> ~/.zshrc
source ~/.zshrc
```

### Completions Features
- **Command completion**: `bamon <TAB>` shows all available commands
- **Flag completion**: `bamon status --<TAB>` shows available flags
- **Subcommand completion**: `bamon config <TAB>` shows config subcommands
- **Context-aware**: Completions change based on current command context

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
  log_file: "~/.local/share/bamon/logs/bamon.log"
  pid_file: "~/.config/bamon/bamon.pid"
  max_concurrent: 10
  history_file: "~/.config/bamon/execution_history.json"
  history_retention_days: 30

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
| `performance --json` | Show performance metrics in JSON format | `bamon performance --json` |
| `performance --verbose` | Show detailed performance information | `bamon performance --verbose` |

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

### Remote Monitoring via SSH

Monitor remote servers from a central location:

```bash
# Monitor disk usage on remote server
bamon add "remote_disk" \
  --command "ssh user@remote-server 'df -h / | awk \"NR==2 {print \\$5}\" | sed \"s/%//\" | awk \"{if(\\$1>80) exit 1; else exit 0}\"'" \
  --interval 300 \
  --description "Monitor disk usage on remote server"

# Check service status on remote server
bamon add "remote_nginx" \
  --command "ssh user@remote-server 'systemctl is-active nginx | grep -q active || exit 1'" \
  --interval 60 \
  --description "Check Nginx service on remote server"

# Monitor multiple servers
SERVERS=("web1.example.com" "web2.example.com" "db.example.com")
for server in "${SERVERS[@]}"; do
  bamon add "remote_${server//\./_}_health" \
    --command "ssh user@${server} 'uptime | awk \"{print \\$10}\" | sed \"s/,//\" | awk \"{if(\\$1>2.0) exit 1; else exit 0}\"'" \
    --interval 60 \
    --description "Monitor CPU load on ${server}"
done
```

**SSH Best Practices:**
- Use SSH key authentication for passwordless access
- Set connection timeouts to avoid hanging connections
- Use dedicated monitoring users with limited privileges
- See [docs/examples.md](docs/examples.md) for comprehensive SSH monitoring examples

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

## ⚡ Performance Monitoring

BAMON includes comprehensive performance monitoring and optimization features:

### System Load Monitoring

BAMON automatically monitors system performance and adapts execution accordingly:

```bash
# View current performance metrics
bamon performance

# Get detailed performance information
bamon performance --verbose

# Export performance data as JSON
bamon performance --json
```

**Performance Features:**
- **Load Detection**: Monitors system load average and prevents execution during high load
- **Resource Awareness**: Tracks CPU, memory, and disk usage
- **Adaptive Scheduling**: Adjusts execution intervals based on system performance
- **Concurrent Execution Management**: Limits simultaneous script execution to prevent system overload

### Performance Metrics

BAMON tracks comprehensive performance data:

- **Execution Times**: Track and optimize script execution duration
- **Success Rates**: Monitor and report script success/failure rates
- **Resource Usage**: Track CPU, memory, and disk usage per script
- **System Health**: Overall system performance indicators
- **Queue Management**: Queue scripts when system is at capacity
- **Priority Scheduling**: Execute high-priority scripts first

### Performance Configuration

Configure performance monitoring in your `config.yaml`:

```yaml
performance:
  enable_monitoring: true
  load_threshold: 0.8          # System load threshold for adaptive scheduling
  optimize_scheduling: true    # Enable intelligent scheduling optimization

daemon:
  max_concurrent: 10           # Maximum simultaneous script executions
```

### Execution History

> **⚠️ Note**: Execution history feature is **not yet implemented**. This is a planned feature for future releases.

BAMON will maintain detailed execution history for performance analysis:

- **Execution Results**: Success/failure status and exit codes
- **Output Capture**: Complete stdout and stderr from each execution
- **Timestamps**: Precise execution timing and duration
- **Resource Metrics**: CPU, memory, and disk usage per execution
- **Retention Policy**: Configurable history retention (default: 30 days)

**Planned History Configuration:**
```yaml
daemon:
  history_file: "~/.config/bamon/execution_history.json"
  history_retention_days: 30
```

**Current Status**: Basic performance data is stored in `~/.config/bamon/performance_data.json`, but detailed execution history is not yet available. See [FUTURE.md](FUTURE.md) for planned features.

## 🔧 Troubleshooting

### Common Issues

#### Daemon fails to start
```bash
# Check if another instance is running
bamon status

# Check logs for errors
tail -f ~/.local/share/bamon/logs/bamon.log

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
bamon start

# Check configuration
bamon config validate --verbose
```

## 🔒 Security Considerations

BAMON implements comprehensive security features to ensure safe script execution:

### Sandboxing and Resource Limits

- **Isolated Environment**: All scripts run in a sandboxed environment with strict resource limits
- **Path Isolation**: Scripts run in temporary directories with limited access to system files
- **Resource Limits**: Configurable limits prevent runaway scripts from consuming system resources
  - **CPU Time**: Maximum CPU time per script execution
  - **Memory**: Maximum virtual memory usage per script
  - **File Size**: Maximum file size for script output
  - **Timeout**: Maximum execution time before forced termination

### Input Validation and Security

- **Input Validation**: Script names and intervals are validated; command content is not validated
- **Command Execution**: Script commands are executed directly without sanitization
- **Permission Model**: Scripts run with the permissions of the user who started the daemon
- **Error Handling**: Graceful handling of script failures prevents system compromise

**⚠️ Security Note**: BAMON executes commands directly without sanitization. Only run trusted scripts and use appropriate user permissions. See [Security Features](#security-features) for planned improvements.

### Security Features

> **📋 Planned Security Enhancements**: Advanced security features are planned for future releases. See [FUTURE.md](FUTURE.md) for detailed security roadmap.

**Current Security Status**:
- ✅ **Basic Input Validation**: Script names and intervals are validated
- ✅ **User Permission Model**: Scripts run with user permissions (no privilege escalation)
- ✅ **Error Handling**: Graceful failure handling prevents system crashes
- ❌ **Command Sanitization**: Not implemented - commands execute directly
- ❌ **Command Whitelisting**: Not implemented - any command can be executed
- ❌ **Path Validation**: Not implemented - any accessible path can be used

**Planned Security Features**:
- **Command Sanitization**: Prevent injection attacks through input validation
- **Command Whitelisting**: Restrict which commands can be executed
- **Path Validation**: Validate and restrict file system access
- **Audit Logging**: Complete audit trail of all security-relevant actions
- **Role-based Access Control**: Different permissions for different users
- **Encrypted Configuration**: Secure storage of sensitive configuration data

### Best Practices

- **Sensitive Data**: Avoid including sensitive information directly in script commands
- **Credential Storage**: Use environment variables or secure credential storage for sensitive data
- **User Isolation**: Consider running BAMON with a dedicated user with minimal permissions
- **Network Security**: Be cautious with network-based health checks and API calls
- **File Permissions**: Ensure configuration files have appropriate permissions (600 or 644)

### Security Configuration

Configure security settings in your `config.yaml`:

```yaml
sandbox:
  timeout: 30                    # Maximum execution time (seconds)
  max_cpu_time: 60              # Maximum CPU time (seconds)
  max_file_size: 10240          # Maximum output file size (bytes)
  max_virtual_memory: 102400    # Maximum virtual memory (KB)
```

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

**Need help?** Check out our [FAQ](docs/FAQ.md) or open an [issue](https://github.com/WawRepo/bamon/issues).
