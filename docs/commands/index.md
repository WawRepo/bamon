# Commands Overview

BAMON provides a comprehensive CLI interface for managing monitored scripts. All commands follow a consistent pattern and provide helpful output.

## Command Structure

```bash
bamon <command> [options] [arguments]
```

## Available Commands

### Core Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `status` | Display current status of all configured scripts | `bamon status [options]` |
| `add` | Add a new script to monitor | `bamon add <name> [options]` |
| `remove` | Remove a script from monitoring | `bamon remove <name> [options]` |
| `list` | List all configured scripts | `bamon list [options]` |
| `now` | Execute all enabled scripts immediately | `bamon now [options]` |

### Daemon Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `start` | Start the daemon process | `bamon start [options]` |
| `stop` | Stop the daemon process | `bamon stop [options]` |
| `restart` | Restart the daemon process | `bamon restart [options]` |

### Utility Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `performance` | Show system performance metrics | `bamon performance [options]` |
| `config` | Configuration management | `bamon config <subcommand> [options]` |

## Global Options

All commands support these global options:

| Option | Short | Description |
|--------|-------|-------------|
| `--help` | `-h` | Show help message for the command |
| `--version` | `-v` | Show version information |
| `--config` | `-c` | Specify custom configuration file path |

## Getting Help

### Command Help

```bash
# Show help for a specific command
bamon <command> --help

# Examples
bamon status --help
bamon add --help
bamon start --help
```

### Global Help

```bash
# Show all available commands
bamon --help

# Show version information
bamon --version
```

## Command Examples

### Basic Workflow

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

### Configuration Management

```bash
# View current configuration
bamon config show

# Edit configuration
bamon config edit

# Validate configuration
bamon config validate

# Reset to defaults
bamon config reset
```

### Performance Monitoring

```bash
# Show performance metrics
bamon performance

# Show detailed performance info
bamon performance --verbose

# Get JSON output
bamon performance --json
```

## Command Reference

For detailed information about each command, see the individual command pages:

- **[status](status.md)** - Status monitoring and reporting
- **[add](add.md)** - Adding monitoring scripts
- **[remove](remove.md)** - Removing monitoring scripts
- **[list](list.md)** - Listing configured scripts
- **[now](now.md)** - Manual script execution
- **[start](start.md)** - Starting the daemon
- **[stop](stop.md)** - Stopping the daemon
- **[restart](restart.md)** - Restarting the daemon
- **[performance](performance.md)** - Performance monitoring
- **[config](config.md)** - Configuration management

## Best Practices

### Command Usage

1. **Always check status** before making changes
2. **Use descriptive names** for scripts
3. **Test scripts manually** before adding them
4. **Monitor performance** regularly
5. **Keep configuration backed up**

### Error Handling

```bash
# Check for errors
bamon status --failed-only

# View detailed status
bamon status

# Check configuration
bamon config validate
```

### Automation

```bash
# Use in scripts
if bamon status --json | jq -e '.scripts[] | select(.name=="health_check" and .status=="failed")'; then
    echo "Health check failed!"
    exit 1
fi
```
