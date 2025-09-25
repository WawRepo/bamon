# BAMON: Bash Daemon Monitor

<div align="center">
  <img src="docs/bamon_logo.png" alt="BAMON Logo" style="width: 50%; height: auto;">
</div>

A lightweight, configurable bash daemon for monitoring and executing bash scripts at specified intervals.

[![Continuous Integration](https://github.com/WawRepo/bamon/actions/workflows/ci.yml/badge.svg)](https://github.com/WawRepo/bamon/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/WawRepo/bamon)](https://github.com/WawRepo/bamon/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 🚀 Quick Start

### Install
```bash
curl -sSL https://github.com/WawRepo/bamon/releases/latest/download/install-repo.sh | bash
```

### Add a Script
```bash
bamon add health_check --command "curl -s https://httpbin.org/status/200" --interval 30
```

### Run
```bash
bamon now
```

## 📖 Documentation

For complete documentation, visit: **[https://wawrepo.github.io/bamon](https://wawrepo.github.io/bamon)**

- **Installation** - Detailed setup instructions
- **Commands** - Complete CLI reference  
- **Configuration** - YAML configuration guide
- **Examples** - Real-world usage scenarios
- **Troubleshooting** - Common issues and solutions

## 🤝 Contributing

We welcome contributions! See our [GitHub repository](https://github.com/WawRepo/bamon) for details.

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.