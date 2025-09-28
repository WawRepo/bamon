% BAMON(1) Bash Daemon Monitor 1.0.0
% BAMON Project
% September 2024

# NAME

bamon - Bash Daemon Monitor

# SYNOPSIS

**bamon** *command* [options]

# DESCRIPTION

Bash Daemon Monitor (bamon) is a powerful tool for monitoring and executing bash scripts at specified intervals. It provides a comprehensive CLI interface for managing monitored scripts, with features including health checks, system resource monitoring, and automated script execution.

BAMON runs as a daemon process that continuously monitors configured scripts and executes them at specified intervals. It provides detailed status reporting, execution history, and performance metrics.

# COMMANDS

**status** [options]
: Display current status of all configured scripts with execution details

**add** *name* [options]
: Add a new script to monitor with specified command and interval

**remove** *name* [options]
: Remove a script from monitoring

**list** [options]
: List all configured scripts with their current status

**now** [options]
: Execute all enabled scripts immediately (manual trigger)

**start** [options]
: Start the daemon process

**stop** [options]
: Stop the daemon process

**restart** [options]
: Restart the daemon process

**config** *subcommand* [options]
: Configuration management commands

**log** [options]
: View and manage daemon log files with filtering and real-time following

**performance** [options]
: Show system performance metrics and optimization status

# OPTIONS

## Global Options

**--help**, **-h**
: Show help message for the command

**--version**, **-v**
: Show version information

**--config** *file*
: Specify custom configuration file path

## Status Command Options


**--failed-only**, **-f**
: Show only failed scripts

**--json**
: Output results in JSON format

**--name** *script_name*
: Show status for specific script only

## Add Command Options

**--command**, **-c** *command*
: Bash command/code to execute (required)

**--interval**, **-i** *seconds*
: Execution interval in seconds (default: 60)

**--description**, **-d** *text*
: Description of what the script does

**--enabled**
: Set script as enabled (default)

**--disabled**
: Set script as disabled

## Remove Command Options

**--force**, **-f**
: Remove without confirmation prompt

## List Command Options

**--enabled-only**, **-e**
: Show only enabled scripts

**--disabled-only**, **-d**
: Show only disabled scripts

**--json**
: Output results in JSON format

## Now Command Options

**--name**, **-n** *script_name*
: Execute only specific script by name

## Start Command Options

**--daemon**, **-d**
: Run in background (daemon mode)

**--foreground**
: Run in foreground (default)

## Stop Command Options

**--force**, **-f**
: Force kill the daemon process

## Config Command Options

**show**
: Display current configuration in YAML format

**edit**
: Open configuration file in default editor

**validate**
: Validate configuration file syntax and structure

## Log Command Options

**--lines**, **-n** *number*
: Number of lines to display (default: 50)

**--follow**, **-f**
: Follow log output in real-time (like tail -f)

**--level**, **-l** *levels*
: Filter by log level (ERROR, WARN, INFO, DEBUG) - comma separated

**--since**, **-s** *time*
: Show logs since time (e.g., '1h', '2d', '2023-01-01')

**--until**, **-u** *time*
: Show logs until time (e.g., '1h', '2d', '2023-01-01')

**--search**, **-g** *pattern*
: Search for keyword or pattern in logs

**--regex**, **-r**
: Treat search pattern as regular expression

**--before**, **-b** *lines*
: Show N lines before each match

**--after**, **-a** *lines*
: Show N lines after each match

**--info**, **-i**
: Show log file information (location, size, etc.)

**--format**, **-o** *format*
: Output format: text, json (default: text)

**--no-color**
: Disable color output

## Performance Command Options

**--json**
: Output performance metrics in JSON format

**--verbose**, **-v**
: Show detailed performance information

# FILES

**~/.config/bamon/config.yaml**
: Default configuration file

**~/.local/share/bamon/logs/bamon.log**
: Default log file

**~/.local/share/bamon/bamon.pid**
: Default PID file

**~/.config/bamon/execution_history.json**
: Execution history storage

**~/.config/bamon/samples/**
: Sample monitoring scripts directory

# CONFIGURATION

BAMON uses YAML configuration files. The main configuration file is located at `~/.config/bamon/config.yaml` by default.

## Configuration Structure

```yaml
daemon:
  default_interval: 60
  log_file: "~/.local/share/bamon/logs/bamon.log"
  pid_file: "~/.local/share/bamon/bamon.pid"

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

## Environment Variables

**BAMON_CONFIG_FILE**
: Override default configuration file path


**BAMON_LOG_FILE**
: Override default log file path

# EXAMPLES

## Basic Usage

Start the daemon in background:
```bash
bamon start --daemon
```

Add a script to monitor disk space:
```bash
bamon add disk_check \
  --command "df -h / | awk 'NR==2 {print \$5}' | sed 's/%//' | awk '{if(\$1>80) exit 1; else exit 0}'" \
  --interval 300 \
  --description "Check if disk usage is under 80%"
```

Check status of all scripts:
```bash
bamon status
```

Execute all scripts immediately:
```bash
bamon now
```

Stop the daemon:
```bash
bamon stop
```

## Advanced Usage

Monitor HTTP health check:
```bash
bamon add health_check \
  --command "curl -s -o /dev/null -w '%{http_code}' https://httpbin.org/status/200" \
  --interval 30 \
  --description "Check if httpbin.org is accessible"
```

Monitor system memory usage:
```bash
bamon add memory_check \
  --command "free -m | awk '/^Mem:/ {print \$3/\$2 * 100.0}' | awk '{if(\$1>85) exit 1; else exit 0}'" \
  --interval 300 \
  --description "Alert if memory usage exceeds 85%"
```

Check if a service is running:
```bash
bamon add nginx_check \
  --command "pgrep nginx > /dev/null || exit 1" \
  --interval 60 \
  --description "Check if Nginx is running"
```

## Configuration Management

View current configuration:
```bash
bamon config show
```

Edit configuration file:
```bash
bamon config edit
```

Validate configuration:
```bash
bamon config validate
```

## Log Management

View recent log entries:
```bash
bamon log
```

Follow logs in real-time:
```bash
bamon log --follow
```

Filter logs by level:
```bash
bamon log --level ERROR,WARN
```

Search for specific patterns:
```bash
# Literal search
bamon log --search "timeout" --before 2 --after 2

# Regex search
bamon log --search ".*failed.*" --regex
bamon log --search "github.*completed" --regex
```

Get log file information:
```bash
bamon log --info
```

Export logs in JSON format:
```bash
bamon log --format json --lines 100
```

## Performance Monitoring

View performance metrics:
```bash
bamon performance
```

Get detailed performance information:
```bash
bamon performance --verbose
```

# EXIT STATUS

**0**
: Success

**1**
: General error

**2**
: Configuration error

**3**
: Script execution error

**4**
: Daemon already running

**5**
: Daemon not running

# SECURITY CONSIDERATIONS

- All scripts run in a sandboxed environment with resource limits
- Scripts execute with the permissions of the user who started the daemon
- Sensitive information should not be included directly in script commands
- Use environment variables or secure credential storage for sensitive data
- Consider running BAMON with a dedicated user with minimal permissions

# TROUBLESHOOTING

## Common Issues

**Daemon fails to start:**
- Check if another instance is running: `bamon status`
- Verify permissions on configuration directory: `ls -la ~/.config/bamon/`
- Check logs for specific errors: `bamon log --level ERROR`

**Scripts not executing:**
- Verify script is enabled: `bamon list`
- Check script syntax: `bash -n your_script.sh`
- Review execution logs: `bamon status`

**Configuration errors:**
- Validate configuration: `bamon config validate`
- Check YAML syntax: `yq eval . ~/.config/bamon/config.yaml`

**Log file issues:**
- Check log file location: `bamon log --info`
- View recent errors: `bamon log --level ERROR --lines 20`
- Follow logs in real-time: `bamon log --follow`
- Search for specific issues: `bamon log --search "error" --level ERROR`

## Debug Mode

Run with verbose logging:
```bash
bamon start --daemon
```

# SEE ALSO

**bash**(1), **curl**(1), **yq**(1), **systemd**(1), **bashly**(1)

For more information about the Bashly CLI framework used to build BAMON, see:
https://github.com/DannyBen/bashly

# BUGS

Report bugs at https://github.com/WawRepo/bamon/issues

# AUTHOR

BAMON Project Team

# COPYRIGHT

Copyright (c) 2024 BAMON Project. Licensed under the MIT License.