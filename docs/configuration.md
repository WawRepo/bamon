# Configuration

BAMON uses YAML configuration files to define monitoring behavior, script settings, and system parameters.

## Configuration File Location

- **User installation**: `~/.config/bamon/config.yaml`
- **System installation**: `/etc/bamon/config.yaml`
- **Custom location**: Use `--config` option or `BAMON_CONFIG_FILE` environment variable

## Configuration Structure

```yaml
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

scripts:
  - name: "script_name"
    command: "bash_command_to_execute"
    interval: 60
    enabled: true
    description: "Script description"
```

## Daemon Configuration

### Basic Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `default_interval` | 60 | Default execution interval in seconds |
| `log_file` | `~/.local/share/bamon/logs/bamon.log` | Log file path |
| `pid_file` | `~/.local/share/bamon/bamon.pid` | PID file path |
| `max_concurrent` | 10 | Maximum concurrent script executions |

### Example

```yaml
daemon:
  default_interval: 120
  log_file: "/var/log/bamon/bamon.log"
  pid_file: "/var/run/bamon.pid"
  max_concurrent: 5
```

## Sandbox Configuration

### Security Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `timeout` | 30 | Script execution timeout in seconds |
| `max_cpu_time` | 60 | Maximum CPU time in seconds |
| `max_file_size` | 10240 | Maximum file size in KB |
| `max_virtual_memory` | 102400 | Maximum virtual memory in KB |

### Example

```yaml
sandbox:
  timeout: 60
  max_cpu_time: 120
  max_file_size: 20480
  max_virtual_memory: 204800
```

## Performance Configuration

### Monitoring Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `enable_monitoring` | true | Enable performance monitoring |
| `load_threshold` | 0.8 | System load threshold for optimization |
| `optimize_scheduling` | true | Enable intelligent scheduling |

### Example

```yaml
performance:
  enable_monitoring: true
  load_threshold: 0.7
  optimize_scheduling: true
```

## Script Configuration

### Script Properties

| Property | Required | Description |
|----------|----------|-------------|
| `name` | Yes | Unique script identifier |
| `command` | Yes | Bash command to execute |
| `interval` | No | Execution interval in seconds |
| `enabled` | No | Whether script is enabled (default: true) |
| `description` | No | Human-readable description |

### Example

```yaml
scripts:
  - name: "health_check"
    command: "curl -s -o /dev/null -w '%{http_code}' https://httpbin.org/status/200"
    interval: 30
    enabled: true
    description: "HTTP health check"

  - name: "disk_usage"
    command: "df -h / | awk 'NR==2 {print \$5}' | sed 's/%//'"
    interval: 300
    enabled: true
    description: "Monitor disk usage"

  - name: "maintenance"
    command: "systemctl restart nginx"
    interval: 3600
    enabled: false
    description: "Hourly Nginx restart"
```

## Environment Variables

### Configuration Override

| Variable | Description |
|----------|-------------|
| `BAMON_CONFIG_FILE` | Override default configuration file path |
| `BAMON_LOG_FILE` | Override default log file path |

### Example

```bash
# Use custom configuration file
export BAMON_CONFIG_FILE="/path/to/custom/config.yaml"
bamon status

# Enable verbose logging
bamon start --daemon
```

## Configuration Management

### View Configuration

```bash
# Show current configuration
bamon config show

# Pretty print configuration
bamon config show --pretty
```

### Edit Configuration

```bash
# Edit configuration file
bamon config edit

# Edit with specific editor
bamon config edit --editor nano
```

### Validate Configuration

```bash
# Validate configuration syntax
bamon config validate

# Validate with verbose output
bamon config validate --verbose
```

### Reset Configuration

```bash
# Reset to default values (creates backup)
bamon config reset

# Reset without confirmation
bamon config reset --force
```

## Advanced Configuration

### Custom Logging

```yaml
daemon:
  log_file: "/var/log/bamon/custom.log"
```

### Resource Limits

```yaml
sandbox:
  timeout: 120
  max_cpu_time: 300
  max_file_size: 51200
  max_virtual_memory: 512000
```

### Performance Tuning

```yaml
performance:
  enable_monitoring: true
  load_threshold: 0.6
  optimize_scheduling: true
  max_concurrent: 20
```

## Configuration Examples

### Development Environment

```yaml
daemon:
  default_interval: 10
  log_file: "~/dev/bamon.log"
  max_concurrent: 5

sandbox:
  timeout: 60
  max_cpu_time: 120

scripts:
  - name: "test_script"
    command: "echo 'Hello World'"
    interval: 10
    enabled: true
```

### Production Environment

```yaml
daemon:
  default_interval: 60
  log_file: "/var/log/bamon/bamon.log"
  pid_file: "/var/run/bamon.pid"
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
  - name: "api_health"
    command: "curl -s https://api.example.com/health"
    interval: 30
    enabled: true
    description: "API health check"
```

## Troubleshooting

### Configuration Validation

```bash
# Check configuration syntax
bamon config validate

# View current configuration
bamon config show
```

### Common Issues

**Invalid YAML syntax**: Use a YAML validator
```bash
# Check YAML syntax
yq eval . ~/.config/bamon/config.yaml
```

**Permission denied**: Check file permissions
```bash
# Check file permissions
ls -la ~/.config/bamon/config.yaml
chmod 644 ~/.config/bamon/config.yaml
```

**Configuration not loading**: Check file location
```bash
# Verify configuration file exists
ls -la ~/.config/bamon/config.yaml
```
