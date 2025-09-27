# Troubleshooting

Common issues and solutions for BAMON.

## Common Issues

### Daemon Issues

#### Daemon Fails to Start

**Symptoms:**
- `bamon start` returns error
- Daemon process not running
- Configuration errors

**Solutions:**

1. **Check if another instance is running:**
   ```bash
   bamon status
   ps aux | grep bamon
   ```

2. **Verify permissions on configuration directory:**
   ```bash
   ls -la ~/.config/bamon/
   chmod 755 ~/.config/bamon/
   chmod 644 ~/.config/bamon/config.yaml
   ```

3. **Check logs for specific errors:**
   ```bash
   tail -f ~/.local/share/bamon/logs/bamon.log
   ```

4. **Validate configuration:**
   ```bash
   bamon config validate
   ```

#### Daemon Already Running

**Symptoms:**
- "Daemon already running" error
- Cannot start new daemon instance

**Solutions:**

1. **Stop existing daemon:**
   ```bash
   bamon stop
   ```

2. **Force stop if needed:**
   ```bash
   bamon stop --force
   ```

3. **Kill process manually:**
   ```bash
   pkill -f bamon
   rm -f ~/.local/share/bamon/bamon.pid
   ```

### Script Execution Issues

#### Scripts Not Executing

**Symptoms:**
- Scripts show as "never" status
- No execution history
- Daemon running but scripts not triggered

**Solutions:**

1. **Verify script is enabled:**
   ```bash
   bamon list
   bamon list --enabled-only
   ```

2. **Check script syntax:**
   ```bash
   bash -n your_script.sh
   ```

3. **Test script manually:**
   ```bash
   bamon now --name script_name
   ```

4. **Review execution logs:**
   ```bash
   bamon status
   tail -f ~/.local/share/bamon/logs/bamon.log
   ```

#### Script Execution Failures

**Symptoms:**
- Scripts show as "failed" status
- Error messages in logs
- Scripts exit with non-zero code

**Solutions:**

1. **Check script output:**
   ```bash
   bamon status --name script_name
   ```

2. **Test script manually:**
   ```bash
   # Run the exact command from configuration
   curl -s https://api.example.com/health
   ```

3. **Check dependencies:**
   ```bash
   # Verify required tools are available
   which curl
   which jq
   which yq
   ```

4. **Review sandbox limits:**
   ```bash
   bamon config show | grep -A 10 sandbox
   ```

### Configuration Issues

#### Configuration Errors

**Symptoms:**
- "Invalid configuration file" error
- YAML syntax errors
- Configuration not loading

**Solutions:**

1. **Validate configuration:**
   ```bash
   bamon config validate
   ```

2. **Check YAML syntax:**
   ```bash
   yq eval . ~/.config/bamon/config.yaml
   ```

3. **Reset to defaults:**
   ```bash
   bamon config reset
   ```

4. **Edit configuration:**
   ```bash
   bamon config edit
   ```

#### Configuration Not Loading

**Symptoms:**
- Default configuration used instead of custom
- Configuration changes not applied
- Wrong configuration file location

**Solutions:**

1. **Check configuration file location:**
   ```bash
   bamon config show
   ```

2. **Use custom configuration file:**
   ```bash
   bamon --config /path/to/config.yaml status
   ```

3. **Set environment variable:**
   ```bash
   export BAMON_CONFIG_FILE="/path/to/config.yaml"
   bamon status
   ```

### Performance Issues

#### High System Load

**Symptoms:**
- System becomes slow
- High CPU usage
- Scripts timing out

**Solutions:**

1. **Check system performance:**
   ```bash
   bamon performance
   ```

2. **Reduce concurrent executions:**
   ```bash
   # Edit configuration
   bamon config edit
   ```

3. **Increase script intervals:**
   ```bash
   bamon add script_name --command "..." --interval 300
   ```

4. **Disable performance monitoring:**
   ```bash
   # Edit configuration
   bamon config edit
   # Set enable_monitoring: false
   ```

#### Memory Issues

**Symptoms:**
- High memory usage
- Scripts killed due to memory limits
- System running out of memory

**Solutions:**

1. **Check memory usage:**
   ```bash
   free -h
   bamon performance
   ```

2. **Adjust sandbox limits:**
   ```bash
   # Edit configuration
   bamon config edit
   # Increase max_virtual_memory
   ```

3. **Reduce script complexity:**
   ```bash
   # Simplify scripts to use less memory
   bamon add simple_script --command "echo 'test'"
   ```

### Installation Issues

#### Command Not Found

**Symptoms:**
- `bamon: command not found`
- Binary not in PATH
- Installation incomplete

**Solutions:**

1. **Check if binary exists:**
   ```bash
   ls -la ~/.local/bin/bamon
   ls -la /usr/local/bin/bamon
   ```

2. **Add to PATH:**
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **Reinstall BAMON:**
   ```bash
   curl -sSL https://github.com/WawRepo/bamon/releases/latest/download/install-repo.sh | bash
   ```

#### Permission Denied

**Symptoms:**
- "Permission denied" errors
- Cannot execute binary
- Cannot write to directories

**Solutions:**

1. **Check file permissions:**
   ```bash
   ls -la ~/.local/bin/bamon
   chmod +x ~/.local/bin/bamon
   ```

2. **Check directory permissions:**
   ```bash
   ls -la ~/.config/bamon/
   chmod 755 ~/.config/bamon/
   ```

3. **Run with sudo (system install):**
   ```bash
   sudo bamon status
   ```

### Dependency Issues

#### Missing Dependencies

**Symptoms:**
- "Command not found" for required tools
- Scripts failing due to missing tools
- Installation errors

**Solutions:**

1. **Install required dependencies:**
   ```bash
   # macOS
   brew install curl yq coreutils
   
   # Ubuntu/Debian
   sudo apt install curl yq coreutils
   
   # RHEL/CentOS
   sudo yum install curl yq coreutils
   ```

2. **Check for required tools:**
   ```bash
   command -v curl yq timeout bash
   ```

3. **Update PATH:**
   ```bash
   # Add tools to PATH if installed in non-standard location
   export PATH="/usr/local/bin:$PATH"
   ```

## Debug Mode

### Enable Verbose Logging

```bash
# Set environment variable

# Start daemon with verbose logging
bamon start --daemon

# Check logs
tail -f ~/.local/share/bamon/logs/bamon.log
```

### Debug Script Execution

```bash
# Test script manually
bamon now --name script_name

# Check detailed status
bamon status --name script_name

# Review execution history
bamon status --json | jq '.scripts[] | select(.name=="script_name")'
```

### Debug Configuration

```bash
# Validate configuration
bamon config validate --verbose

# Show current configuration
bamon config show --pretty

# Test configuration loading
bamon --config /path/to/config.yaml status
```

## Log Analysis

### Log File Locations

- **User installation**: `~/.local/share/bamon/logs/bamon.log`
- **System installation**: `/var/log/bamon/bamon.log`
- **Custom location**: As configured in `config.yaml`

### Log Analysis Commands

```bash
# View recent logs
tail -f ~/.local/share/bamon/logs/bamon.log

# Search for errors
grep -i error ~/.local/share/bamon/logs/bamon.log

# Search for specific script
grep "script_name" ~/.local/share/bamon/logs/bamon.log

# Count script executions
grep "Executing script" ~/.local/share/bamon/logs/bamon.log | wc -l
```

### Common Log Patterns

```bash
# Script execution success
[2024-01-15 10:30:15] [health_check] Script executed successfully

# Script execution failure
[2024-01-15 10:30:15] [health_check] Script execution failed: exit code 1

# Daemon startup
[2024-01-15 10:30:00] [bamon] Daemon started successfully

# Configuration error
[2024-01-15 10:30:00] [bamon] Configuration validation failed: invalid YAML syntax
```

## Getting Help

### Self-Diagnosis

1. **Check system status:**
   ```bash
   bamon status
   bamon performance
   ```

2. **Validate configuration:**
   ```bash
   bamon config validate
   ```

3. **Review logs:**
   ```bash
   tail -f ~/.local/share/bamon/logs/bamon.log
   ```

### Reporting Issues

When reporting issues, include:

1. **BAMON version:**
   ```bash
   bamon --version
   ```

2. **System information:**
   ```bash
   uname -a
   ```

3. **Configuration:**
   ```bash
   bamon config show
   ```

4. **Error logs:**
   ```bash
   tail -f ~/.local/share/bamon/logs/bamon.log
   ```

5. **Steps to reproduce**

### Community Support

- **GitHub Issues**: https://github.com/WawRepo/bamon/issues
- **Documentation**: https://wawrepo.github.io/bamon/
- **Discussions**: https://github.com/WawRepo/bamon/discussions
