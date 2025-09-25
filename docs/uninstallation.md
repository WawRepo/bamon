# Uninstallation

Removing BAMON is straightforward and can be done in a few simple steps.

## Quick Uninstall

### User Installation

```bash
# Remove binary
rm ~/.local/bin/bamon

# Remove configuration (optional)
rm -rf ~/.config/bamon

# Remove logs (optional)
rm -rf ~/.local/share/bamon

# Remove from PATH (if manually added)
# Edit ~/.bashrc, ~/.zshrc, etc. and remove the BAMON path
```

### System Installation

```bash
# Remove binary
sudo rm /usr/local/bin/bamon

# Remove configuration (optional)
sudo rm -rf /etc/bamon

# Remove logs (optional)
sudo rm -rf /var/log/bamon
```

## Complete Removal

To completely remove BAMON and all associated files:

### 1. Stop BAMON Daemon

```bash
# Stop any running daemon
bamon stop

# Force stop if needed
bamon stop --force
```

### 2. Remove Binary

```bash
# Find BAMON binary location
which bamon

# Remove binary
rm $(which bamon)
```

### 3. Remove Configuration Files

```bash
# Remove user configuration
rm -rf ~/.config/bamon

# Remove system configuration (if system install)
sudo rm -rf /etc/bamon
```

### 4. Remove Log Files

```bash
# Remove user logs
rm -rf ~/.local/share/bamon

# Remove system logs (if system install)
sudo rm -rf /var/log/bamon
```

### 5. Remove from PATH

Edit your shell configuration files and remove BAMON-related PATH entries:

```bash
# Edit shell config files
nano ~/.bashrc    # For Bash
nano ~/.zshrc     # For Zsh
nano ~/.fish/config.fish  # For Fish

# Remove or comment out lines like:
# export PATH="$HOME/.local/bin:$PATH"
# eval "$(bamon completions)"
```

### 6. Remove Shell Completions

```bash
# Remove completion setup from shell config
# Edit ~/.bashrc, ~/.zshrc, etc. and remove:
# eval "$(bamon completions)"
```

## Verification

After uninstallation, verify BAMON is completely removed:

```bash
# Check if binary exists
which bamon
# Should return: bamon not found

# Check if configuration exists
ls ~/.config/bamon
# Should return: No such file or directory

# Check if logs exist
ls ~/.local/share/bamon
# Should return: No such file or directory
```

## Cleanup Script

For automated cleanup, you can use this script:

```bash
#!/bin/bash
# BAMON cleanup script

echo "Stopping BAMON daemon..."
bamon stop 2>/dev/null || true

echo "Removing BAMON binary..."
rm -f ~/.local/bin/bamon
rm -f /usr/local/bin/bamon

echo "Removing configuration..."
rm -rf ~/.config/bamon
rm -rf /etc/bamon

echo "Removing logs..."
rm -rf ~/.local/share/bamon
rm -rf /var/log/bamon

echo "BAMON has been completely removed."
```

## Reinstallation

If you want to reinstall BAMON after removal:

```bash
# Reinstall using the same method as before
curl -sSL https://github.com/WawRepo/bamon/releases/latest/download/install-repo.sh | bash
```

## Troubleshooting

### Common Issues

**"bamon: command not found"**: This is expected after uninstallation.

**Configuration still exists**: Manually remove configuration directories:
```bash
rm -rf ~/.config/bamon
```

**Logs still exist**: Manually remove log directories:
```bash
rm -rf ~/.local/share/bamon
```

**PATH still contains BAMON**: Edit your shell configuration files to remove BAMON paths.

### Getting Help

If you encounter issues during uninstallation:

1. Check the [Troubleshooting Guide](https://wawrepo.github.io/bamon/troubleshooting/)
2. Open an issue on [GitHub](https://github.com/WawRepo/bamon/issues)
