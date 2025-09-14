# BAMON Sample Scripts

This directory contains sample scripts that demonstrate how to create monitoring scripts for BAMON.

## Available Scripts

### 1. health_check.sh
**Purpose**: Performs HTTP health checks
**Features**:
- Configurable URL and timeout
- Returns HTTP status code
- Clear success/failure messages
- Proper exit codes (0 for success, 1 for failure)

**Usage**:
```bash
# Add to BAMON
bamon add health_check '/path/to/samples/health_check.sh' --interval 60

# Run manually
./health_check.sh
```

### 2. disk_usage.sh
**Purpose**: Monitors disk usage and alerts when threshold is exceeded
**Features**:
- Configurable threshold (default: 80%)
- Configurable mount point (default: /)
- Clear warning messages
- Proper exit codes (0 for OK, 1 for warning)

**Usage**:
```bash
# Add to BAMON
bamon add disk_usage '/path/to/samples/disk_usage.sh' --interval 300

# Run manually
./disk_usage.sh
```

### 3. github_status.sh
**Purpose**: Checks GitHub's service status using their official status API
**Features**:
- Uses GitHub's official status API
- Configurable timeout (default: 10s)
- JSON response parsing with jq
- Clear status messages
- Proper exit codes (0 for operational, 1 for issues)

**Usage**:
```bash
# Add to BAMON
bamon add github_status '/path/to/samples/github_status.sh' --interval 30

# Run manually
./github_status.sh
```

## Creating Your Own Scripts

When creating monitoring scripts for BAMON, follow these guidelines:

### 1. Exit Codes
- **0**: Success (script completed successfully)
- **1**: Failure (script failed or detected an issue)
- **Other**: Will be treated as failure

### 2. Output
- **stdout**: Will be captured and shown in `bamon status`
- **stderr**: Will be captured and shown in error messages
- Keep output concise for table view (use `bamon status --json` for full details)

### 3. Performance
- Scripts should complete quickly (under 30 seconds by default)
- Use timeouts for network operations
- Avoid blocking operations

### 4. Error Handling
- Always handle errors gracefully
- Provide meaningful error messages
- Use proper exit codes

### Example Script Template
```bash
#!/usr/bin/env bash

# Your script description
# This script does X and returns 0 for success, 1 for failure

# Configuration
THRESHOLD=80
TIMEOUT=10

# Main logic
if your_check_here; then
    echo "Check passed: details here"
    exit 0
else
    echo "Check failed: reason here"
    exit 1
fi
```

## Integration with BAMON

These sample scripts are automatically installed with BAMON and can be enabled using:

```bash
# List available scripts
bamon list

# Add a sample script
bamon add script_name '/path/to/script.sh' --interval 60

# Enable/disable scripts
bamon add script_name --enable
bamon add script_name --disable

# Remove scripts
bamon remove script_name
```
