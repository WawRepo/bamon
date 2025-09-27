# BAMON: Bash Daemon Monitor

<div align="center">
  <img src="docs/bamon_logo.png" alt="BAMON Logo" style="width: 50%; height: auto;">
</div>

## Why BAMON?

Countless monitoring tools exist, but BAMON fills a specific gap. We all have those commands we run in the terminal just to check something - maybe a GitHub status check, SSH to a dev VM to check load, or in my case, getting a full overview of non production multiple ArgoCD applications.

The goal of BAMON is simple: when you have a command or script you'd like to run in a repetitive manner, that just needs the context of your user environment, BAMON is the tool for you.


[![Continuous Integration](https://github.com/WawRepo/bamon/actions/workflows/ci.yml/badge.svg)](https://github.com/WawRepo/bamon/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/WawRepo/bamon)](https://github.com/WawRepo/bamon/releases)
[![Documentation](https://github.com/WawRepo/bamon/actions/workflows/docs.yml/badge.svg)](https://github.com/WawRepo/bamon/actions/workflows/docs.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 🚀 Quick Start

### Install
```bash
curl -sSL https://github.com/WawRepo/bamon/releases/latest/download/install-repo.sh | bash
```

### Add a Script
```bash
# Health check example
bamon add health_check --command "curl -s https://httpbin.org/status/200" --interval 30

# GitHub status check example
bamon add github_check --command "curl -s https://www.githubstatus.com/api/v2/status.json | jq -e '.status.indicator == \"none\"' > /dev/null || { echo \"not green\"; exit 1; }" --interval 30
```

### Run
```bash
bamon now
```

## 📖 Documentation

For complete documentation, visit: **[https://wawrepo.github.io/bamon](https://wawrepo.github.io/bamon)**

## 🤝 Contributing

We welcome contributions! See our [GitHub repository](https://github.com/WawRepo/bamon) for details.

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.