# BAMON Frequently Asked Questions (FAQ)

## General Questions

### What is BAMON?

BAMON (Bash Daemon Monitor) is a powerful tool for monitoring and executing bash scripts at specified intervals. It provides a comprehensive CLI interface for managing monitored scripts, with features including health checks, system resource monitoring, and automated script execution.

### Why should I use BAMON instead of cron?

BAMON offers several advantages over cron:

- **Real-time monitoring**: Continuous monitoring with immediate status reporting
- **Resource management**: Built-in sandboxing and resource limits
- **Rich status reporting**: Detailed execution history and performance metrics
- **CLI management**: Easy script management without editing crontab files
- **Error handling**: Better error reporting and debugging capabilities
- **Configuration management**: YAML-based configuration with validation

### Is BAMON suitable for production use?

Yes, BAMON is designed for production use with features like:
- Sandboxed script execution with resource limits
- Comprehensive logging and error handling
- Performance monitoring and optimization
- Configuration validation and management
- Systemd integration support

## Installation Questions

### How do I install BAMON?

The easiest way is using the installation script:

```bash
git clone https://github.com/WawRepo/bamon.git
cd bamon
chmod +x install.sh
./install.sh
```

### What are the system requirements?

- **bash** 4.0+ (system default or Homebrew)
- **curl** (for HTTP health checks)
- **yq** (YAML processor)
- **timeout/gtimeout** (GNU coreutils)
- Standard Unix tools (awk, sed, grep, etc.)

### Can I install BAMON without Ruby/Bashly?

Yes! The simplified installation script doesn't require Ruby or Bashly. It installs a pre-built binary directly from the repository.

### How do I set up development environment?

For development, you'll need Ruby and Bashly:

```bash
# macOS
brew install ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="$(ruby -r rubygems -e "puts Gem.bindir"):$PATH"
gem install bashly

# Ubuntu/Debian
sudo apt install ruby ruby-dev
gem install bashly
```

## Configuration Questions

### Where is the configuration file located?

The default configuration file is at `~/.config/bamon/config.yaml`. You can specify a custom location with the `--config` option.

### How do I edit the configuration?

Use the built-in config management commands:

```bash
# View current configuration
bamon config show

# Edit configuration
bamon config edit

# Validate configuration
bamon config validate
```

### What configuration options are available?

Key configuration sections:
- **daemon**: Daemon settings (intervals, logging, concurrency)
- **sandbox**: Script execution limits (timeout, memory, CPU)
- **performance**: Performance monitoring and optimization
- **scripts**: Individual script definitions

### Can I have multiple configuration files?

Yes, you can specify different configuration files:

```bash
bamon start --config /path/to/custom/config.yaml
```

## Usage Questions

### How do I start the daemon?

```bash
# Start in background (daemon mode)
bamon start --daemon

# Start in foreground (for testing)
bamon start
```

### How do I add a script to monitor?

```bash
bamon add "script_name" \
  --command "your_bash_command" \
  --interval 60 \
  --description "What this script does"
```

### How do I check the status of all scripts?

```bash
# Basic status
bamon status

# Only failed scripts
bamon status --failed-only

# JSON output
bamon status --json
```

### How do I remove a script from monitoring?

```bash
bamon remove script_name
```

### How do I execute all scripts immediately?

```bash
# Execute all scripts
bamon now

# Execute specific script
bamon now --name script_name
```

## Troubleshooting Questions

### The daemon won't start. What should I check?

1. **Check if another instance is running:**
   ```bash
   bamon status
   ```

2. **Check logs for errors:**
   ```bash
   tail -f ~/.local/share/bamon/logs/bamon.log
   ```

3. **Verify permissions:**
   ```bash
   ls -la ~/.config/bamon/
   ```

4. **Check configuration:**
   ```bash
   bamon config validate
   ```

### Scripts are not executing. What's wrong?

1. **Check if scripts are enabled:**
   ```bash
   bamon list
   ```

2. **Test script manually:**
   ```bash
   bash -c "your_script_command"
   ```

3. **Check execution logs:**
   ```bash
   bamon status
   ```

4. **Verify script permissions:**
   ```bash
   ls -la /path/to/your/script
   ```

### I'm getting "command not found" errors. How do I fix this?

This usually means the command isn't in the PATH when BAMON runs. Solutions:

1. **Use full paths:**
   ```bash
   bamon add "check" --command "/usr/bin/curl -s https://example.com"
   ```

2. **Set PATH in script:**
   ```bash
   bamon add "check" --command "export PATH=/usr/local/bin:\$PATH && your_command"
   ```

3. **Create wrapper script:**
   ```bash
   # Create wrapper script with proper PATH
   echo '#!/bin/bash
   export PATH=/usr/local/bin:$PATH
   your_command' > /path/to/wrapper.sh
   chmod +x /path/to/wrapper.sh
   
   bamon add "check" --command "/path/to/wrapper.sh"
   ```

### Scripts are timing out. How do I fix this?

1. **Check sandbox timeout settings:**
   ```bash
   bamon config show | grep timeout
   ```

2. **Increase timeout in configuration:**
   ```yaml
   sandbox:
     timeout: 60  # Increase from default 30 seconds
   ```

3. **Optimize script performance:**
   - Use more efficient commands
   - Reduce data processing
   - Cache results when possible

### How do I debug script execution?

1. **Run with debug logging:**
   ```bash
   bamon start --daemon
   ```

2. **Test script manually:**
   ```bash
   bash -c "your_script_command"
   ```

3. **Check status:**
   ```bash
   bamon status
   ```

4. **View execution history:**
   ```bash
   cat ~/.config/bamon/execution_history.json | jq .
   ```

## Performance Questions

### How much system resources does BAMON use?

BAMON is designed to be lightweight:
- **Memory**: < 10MB RAM when idle
- **CPU**: < 1% CPU when idle
- **Disk**: Minimal (logs and configuration files)

### How many scripts can BAMON monitor simultaneously?

The default limit is 10 concurrent scripts, but this can be configured:

```yaml
daemon:
  max_concurrent: 20  # Increase as needed
```

### How do I optimize BAMON performance?

1. **Enable performance monitoring:**
   ```yaml
   performance:
     enable_monitoring: true
     optimize_scheduling: true
   ```

2. **Adjust script intervals:**
   - Use longer intervals for non-critical checks
   - Group related checks together

3. **Monitor system load:**
   ```bash
   bamon performance
   ```

## Security Questions

### Is BAMON secure for production use?

Yes, BAMON includes several security features:
- **Sandboxing**: Scripts run in isolated environments
- **Resource limits**: CPU, memory, and file size limits
- **Permission isolation**: Scripts run with user permissions
- **Input validation**: All inputs are validated before execution

### How do I run BAMON securely?

1. **Use dedicated user:**
   ```bash
   sudo useradd -r -s /bin/false bamon
   sudo -u bamon bamon start --daemon
   ```

2. **Limit script permissions:**
   - Use specific users for sensitive operations
   - Avoid running as root when possible

3. **Validate script content:**
   - Review scripts before adding them
   - Use trusted script sources

### Can scripts access sensitive system files?

Scripts run with the permissions of the user who started BAMON. If you start BAMON as a regular user, scripts won't have access to system files unless explicitly granted.

## Integration Questions

### Can I integrate BAMON with monitoring systems?

Yes, BAMON supports several integration methods:

1. **JSON output for APIs:**
   ```bash
   bamon status --json | curl -X POST -d @- https://monitoring-api.com/webhook
   ```

2. **Log file monitoring:**
   ```bash
   tail -f ~/.local/share/bamon/logs/bamon.log | logger -t bamon
   ```

3. **Custom webhooks:**
   ```bash
   # Create webhook script
   bamon add "webhook" --command "curl -X POST https://webhook.url -d '{\"status\": \"ok\"}'"
   ```

### Can I use BAMON with systemd?

Yes, you can create a systemd service file:

```ini
[Unit]
Description=BAMON Daemon Monitor
After=network.target

[Service]
Type=forking
User=bamon
Group=bamon
ExecStart=/usr/local/bin/bamon start --daemon
ExecStop=/usr/local/bin/bamon stop
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Can I use BAMON in Docker containers?

Yes, BAMON works well in Docker containers. Consider:

1. **Use appropriate base images** with required dependencies
2. **Set proper resource limits** in Docker
3. **Mount configuration** from host or use environment variables
4. **Handle logging** appropriately for containerized environments

## Advanced Questions

### How do I create custom monitoring scripts?

1. **Create script file:**
   ```bash
   cat > ~/.config/bamon/samples/custom_check.sh << 'EOF'
   #!/bin/bash
   # Your monitoring logic here
   if [ condition ]; then
       echo "OK: Everything is fine"
       exit 0
   else
       echo "ERROR: Something is wrong"
       exit 1
   fi
   EOF
   
   chmod +x ~/.config/bamon/samples/custom_check.sh
   ```

2. **Add to BAMON:**
   ```bash
   bamon add "custom_check" \
     --command "~/.config/bamon/samples/custom_check.sh" \
     --interval 300
   ```

### How do I monitor multiple servers with BAMON?

For multiple servers, consider:

1. **Centralized monitoring**: Run BAMON on a central server that monitors remote services
2. **Distributed monitoring**: Run BAMON on each server and aggregate results
3. **Hybrid approach**: Local monitoring with centralized reporting

### Can I use BAMON for CI/CD pipelines?

Yes, BAMON can be integrated into CI/CD:

1. **Pre-deployment checks**: Verify system health before deployment
2. **Post-deployment verification**: Ensure services are running after deployment
3. **Continuous monitoring**: Monitor application health during development

### How do I backup BAMON configuration?

```bash
# Backup configuration
cp -r ~/.config/bamon /backup/bamon-$(date +%Y%m%d)

# Backup specific files
cp ~/.config/bamon/config.yaml /backup/
cp ~/.config/bamon/samples/ /backup/ -r
```

## Getting Help

### Where can I get help?

1. **Documentation**: Check the README.md and examples
2. **Issues**: Open an issue on GitHub
3. **Community**: Join discussions in the project repository
4. **Check logs**: Review log files for detailed execution information

### How do I report bugs?

1. **Check existing issues** on GitHub
2. **Create new issue** with:
   - BAMON version (`bamon --version`)
   - System information (`uname -a`)
   - Configuration (`bamon config show`)
   - Error logs (`tail -f ~/.local/share/bamon/logs/bamon.log`)
   - Steps to reproduce

### How do I contribute to BAMON?

1. **Fork the repository**
2. **Create feature branch**
3. **Make changes and test**
4. **Submit pull request**

See the [GitHub repository](https://github.com/WawRepo/bamon) for contribution guidelines.

---

**Still have questions?** Open an [issue](https://github.com/WawRepo/bamon/issues) or check the [examples](https://wawrepo.github.io/bamon/examples/) for more detailed usage scenarios.
