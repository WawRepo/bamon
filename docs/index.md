# BAMON Documentation

![BAMON Logo](bamon_logo.png)

Welcome to the BAMON documentation! BAMON (Bash Daemon Monitor) is a powerful tool for monitoring and executing bash scripts at specified intervals.

## What is BAMON?

BAMON is a lightweight, configurable monitoring solution that runs as a daemon process, continuously monitoring configured scripts and executing them at specified intervals. It provides:

- **Automated Script Execution**: Run scripts at configurable intervals
- **Sandboxed Environment**: Secure execution with resource limits
- **Performance Monitoring**: Built-in system metrics and optimization
- **Flexible Configuration**: YAML-based configuration with CLI management
- **Comprehensive Status**: Detailed execution history and status reporting

## Quick Start

### Installation

```bash
# Download and install from latest release
curl -sSL https://github.com/WawRepo/bamon/releases/latest/download/install-repo.sh | bash
```

### Basic Usage

```bash
# Start the daemon
bamon start --daemon

# Add a monitoring script
bamon add health_check --command "curl -s https://httpbin.org/status/200" --interval 30

# Check status
bamon status

# Execute all scripts immediately
bamon now

# Stop the daemon
bamon stop
```

## Key Features

### 🔄 Automated Monitoring
Execute scripts at configurable intervals with built-in scheduling.

### 🛡️ Sandboxed Execution
Secure script execution with resource limits and timeout controls.

### 📊 Performance Monitoring
Built-in system metrics collection and performance optimization.

### ⚙️ Flexible Configuration
YAML-based configuration with comprehensive CLI management.

### 🔍 Comprehensive Status
Detailed execution history, status reporting, and error tracking.

### 🚀 Easy Installation
One-command installation from GitHub releases with automatic setup.

## Documentation Structure

- **[Installation](installation.md)** - Detailed installation instructions for different platforms
- **[Commands](commands/index.md)** - Complete CLI command reference
- **[Configuration](configuration.md)** - Configuration options and examples
- **[Examples](examples.md)** - Real-world usage examples and use cases
- **[Troubleshooting](troubleshooting.md)** - Common issues and solutions
- **[API Reference](api.md)** - Technical details for developers

## Getting Help

- **Documentation**: Browse the sections above for detailed information
- **Issues**: Report bugs or request features on [GitHub Issues](https://github.com/WawRepo/bamon/issues)
- **Releases**: Check the [latest releases](https://github.com/WawRepo/bamon/releases) for updates

## Contributing

We welcome contributions! Please see our [GitHub repository](https://github.com/WawRepo/bamon) for details on how to contribute to BAMON.
