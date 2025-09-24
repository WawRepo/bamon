# BAMON

![BAMON Logo](docs/bamon_logo.png)

**Bash Daemon Monitor** - A lightweight, configurable monitoring solution for bash scripts

[![CI](https://github.com/WawRepo/bamon/workflows/CI/badge.svg)](https://github.com/WawRepo/bamon/actions)
[![Release](https://img.shields.io/github/v/release/WawRepo/bamon)](https://github.com/WawRepo/bamon/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## What is BAMON?

BAMON is a powerful bash daemon that monitors and executes scripts at specified intervals. It provides comprehensive CLI management, health checks, system resource monitoring, and automated script execution with sandboxed environments.

## Quick Install

```bash
# Download and install from latest release
curl -sSL https://github.com/WawRepo/bamon/releases/latest/download/install-repo.sh | bash
```

This will:
- Download the latest BAMON binary
- Install to `~/.local/bin` (user) or `/usr/local/bin` (system)
- Set up default configuration and sample scripts
- Add BAMON to your PATH

## Basic Usage

```bash
# Start monitoring daemon
bamon start --daemon

# Add a health check script
bamon add health_check --command "curl -s https://httpbin.org/status/200" --interval 30

# Check status
bamon status

# Execute all scripts now
bamon now

# Stop daemon
bamon stop
```

## Features

- **🔄 Automated Monitoring**: Execute scripts at configurable intervals
- **🛡️ Sandboxed Execution**: Secure script execution with resource limits
- **📊 Performance Monitoring**: Built-in system metrics and optimization
- **⚙️ Flexible Configuration**: YAML-based configuration with CLI management
- **🔍 Comprehensive Status**: Detailed execution history and status reporting
- **🚀 Easy Installation**: One-command installation from GitHub releases

## Documentation

- **[Installation Guide](https://wawrepo.github.io/bamon/installation/)** - Detailed installation instructions
- **[Command Reference](https://wawrepo.github.io/bamon/commands/)** - Complete CLI documentation
- **[Configuration Guide](https://wawrepo.github.io/bamon/configuration/)** - Configuration options and examples
- **[Examples](https://wawrepo.github.io/bamon/examples/)** - Real-world usage examples
- **[Troubleshooting](https://wawrepo.github.io/bamon/troubleshooting/)** - Common issues and solutions

## Development

```bash
# Clone repository
git clone https://github.com/WawRepo/bamon.git
cd bamon

# Install dependencies
brew install bashly yq

# Generate binary
bashly generate

# Run tests
./test/run_container_tests.sh
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](https://wawrepo.github.io/bamon/contributing/) for details.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Links

- **Documentation**: https://wawrepo.github.io/bamon/
- **Issues**: https://github.com/WawRepo/bamon/issues
- **Releases**: https://github.com/WawRepo/bamon/releases