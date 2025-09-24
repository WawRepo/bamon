# config Command

Manage BAMON configuration files and settings.

## Syntax

```bash
bamon config <subcommand> [options]
```

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `show` | Display current configuration |
| `edit` | Edit configuration file |
| `validate` | Validate configuration syntax |
| `reset` | Reset to default configuration |

## Examples

### Show Configuration

```bash
# Display current configuration
bamon config show
```

**Output:**
```
BAMON Configuration
==================

Daemon Settings:
  Default Interval: 60s
  Log File: ~/.local/share/bamon/logs/bamon.log
  PID File: ~/.local/share/bamon/bamon.pid
  Max Concurrent: 10

Sandbox Settings:
  Timeout: 30s
  Max CPU Time: 60s
  Max File Size: 10240KB
  Max Virtual Memory: 102400KB

Performance Settings:
  Monitoring: enabled
  Load Threshold: 0.8
  Optimize Scheduling: enabled

Scripts: 3 configured
```

### Edit Configuration

```bash
# Edit configuration file
bamon config edit
```

**Output:**
```
Opening configuration file in editor...
```

### Validate Configuration

```bash
# Validate configuration syntax
bamon config validate
```

**Output:**
```
Configuration validation passed
```

### Reset Configuration

```bash
# Reset to default configuration
bamon config reset
```

**Output:**
```
Configuration reset to defaults
Backup saved to: ~/.config/bamon/config.yaml.backup
```

## Related Commands

- **[status](status.md)** - Check daemon status
- **[start](start.md)** - Start the daemon process
- **[performance](performance.md)** - Show performance metrics
