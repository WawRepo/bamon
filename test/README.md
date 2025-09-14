# BAMON Testing Environment

This directory contains a comprehensive testing infrastructure for BAMON using Ubuntu containers and BATS (Bash Automated Testing System).

## Overview

The testing environment provides:
- **Fresh Ubuntu Container**: Clean environment with no pre-installed dependencies
- **BATS Testing Framework**: Automated testing with comprehensive test coverage
- **Docker Integration**: Easy containerized testing
- **Cross-Platform Validation**: Ensures BAMON works correctly in different environments
- **Pre-built BAMON Binary**: Uses existing BAMON binary instead of building in container

## Directory Structure

```
test/
├── README.md                           # This file
├── config.yaml                         # Test configuration
├── run_container_tests.sh              # Main test runner
├── container/
│   ├── Dockerfile                      # Ubuntu container definition
│   ├── docker-compose.yml              # Docker Compose configuration
│   ├── setup.sh                        # Container setup script
│   ├── run_tests.sh                    # Test execution script
│   └── test_helpers.sh                 # Common test functions
├── installation/                       # Installation tests
│   ├── test_user_installation.bats
│   ├── test_system_installation.bats
│   └── test_dependency_detection.bats
├── commands/                           # CLI command tests
│   ├── test_status_command.bats
│   ├── test_add_command.bats
│   ├── test_remove_command.bats
│   ├── test_list_command.bats
│   ├── test_now_command.bats
│   └── test_start_stop_restart_commands.bats
├── daemon/                             # Daemon functionality tests
│   ├── test_daemon_execution.bats
│   ├── test_daemon_scheduling.bats
│   ├── test_daemon_logging.bats
│   └── test_daemon_performance.bats
└── performance/                        # Performance monitoring tests
    ├── test_performance_monitoring.bats
    ├── test_json_output.bats
    └── test_error_handling.bats
```

## Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Git (for cloning BATS)
- BAMON binary built and available in project root

### Running Tests

1. **Build BAMON binary first:**
   ```bash
   bashly generate
   ```

2. **Run all tests in container:**
   ```bash
   ./test/run_container_tests.sh
   ```

3. **Run specific test categories:**
   ```bash
   # Installation tests only
   bats test/installation/*.bats
   
   # Command tests only
   bats test/commands/*.bats
   
   # Daemon tests only
   bats test/daemon/*.bats
   ```

4. **Run individual test files:**
   ```bash
   bats test/installation/test_user_installation.bats
   ```

### Manual Container Testing

1. **Build the container:**
   ```bash
   cd test/container
   docker-compose build
   ```

2. **Run interactive container:**
   ```bash
   docker-compose run --rm bamon-test /bin/bash
   ```

3. **Setup test environment inside container:**
   ```bash
   /app/test/container/setup.sh
   ```

## Test Categories

### Installation Tests
- **User Installation**: Tests `~/.local/bin` installation
- **System Installation**: Tests `/usr/local/bin` installation  
- **Dependency Detection**: Tests installation with all dependencies present
- **Configuration Creation**: Tests default config and sample scripts
- **Binary Installation**: Tests BAMON binary placement and execution

### Command Tests
- **Status Command**: Tests status display and filtering
- **Add Command**: Tests script addition functionality
- **Remove Command**: Tests script removal functionality
- **List Command**: Tests script listing
- **Now Command**: Tests manual script execution
- **Start/Stop/Restart**: Tests daemon management

### Daemon Tests
- **Execution**: Tests script execution at intervals
- **Scheduling**: Tests interval-based scheduling
- **Logging**: Tests log file creation and content
- **Performance**: Tests performance monitoring integration

### Performance Tests
- **Monitoring**: Tests performance metrics collection
- **JSON Output**: Tests JSON formatting and validity
- **Error Handling**: Tests error detection and reporting

## Test Configuration

The `test/config.yaml` file contains test settings:

```yaml
test_settings:
  timeout: 60          # Test timeout in seconds
  retry_count: 3       # Number of retries for flaky tests
  verbose: true        # Verbose output

test_cases:
  - name: installation
    description: "Test installation script functionality"
    tests: [...]
  # ... more test categories
```

## Writing New Tests

### Test File Structure
```bash
#!/usr/bin/env bats
# test/category/test_feature.bats

load "../container/test_helpers.sh"

@test "Test description" {
  # Test implementation
  run some_command
  [ "$status" -eq 0 ]
  [[ "$output" == *"expected"* ]]
}
```

### Available Helper Functions

- `setup()`: Runs before each test
- `teardown()`: Runs after each test
- `install_bamon(mode)`: Installs BAMON (user/system/dev)
- `verify_installation(mode)`: Verifies installation
- `run_bamon(mode, args...)`: Runs BAMON command
- `wait_for_daemon()`: Waits for daemon to start
- `stop_daemon()`: Stops daemon

### Test Best Practices

1. **Use descriptive test names**
2. **Test both success and failure cases**
3. **Clean up after tests** (handled by teardown)
4. **Use appropriate assertions**
5. **Test edge cases and error conditions**

## Container Environment

The Ubuntu container includes:
- **Ubuntu Latest**: Fresh Ubuntu installation
- **Minimal Dependencies**: Only required packages
- **Test User**: Non-root user with sudo access
- **BATS Framework**: Latest version with support libraries
- **BAMON Dependencies**: curl, jq, yq, timeout, bash, bc, coreutils
- **Pre-built BAMON**: Uses existing BAMON binary from host system

## Troubleshooting

### Common Issues

1. **Docker not running**: Ensure Docker daemon is started
2. **Permission issues**: Check file permissions on test scripts
3. **Test failures**: Check logs for specific error messages
4. **Container build failures**: Ensure Dockerfile syntax is correct

### Debug Mode

Run tests with verbose output:
```bash
bats --verbose test/installation/*.bats
```

### Container Debugging

Access container shell for debugging:
```bash
docker-compose run --rm bamon-test /bin/bash
```

## Continuous Integration

The testing environment is designed to work with CI/CD systems:

1. **Docker-based**: No external dependencies
2. **Isolated**: Each test run is clean
3. **Reproducible**: Consistent results across environments
4. **Comprehensive**: Covers all major functionality

## Current Test Status

### Test Results (as of latest run):
- **Installation Tests**: 16/16 PASSING ✅ (100% success rate)
- **Command Tests**: 7/12 PASSING ⚠️ (58% success rate)
- **Overall**: 23/28 tests passing (82% success rate)

### Known Issues:
- **Add Command Tests**: Some tests failing due to command implementation details
- **Remove Command Tests**: Some tests failing due to command implementation details
- **Status Command Tests**: All passing ✅
- **Installation Tests**: All passing ✅

### Test Coverage:
- ✅ **Installation**: User/system installation, dependency detection, binary placement
- ✅ **Status Command**: Help, default scripts, JSON output, filtering, specific scripts
- ⚠️ **Add/Remove Commands**: Partial coverage, some edge cases need attention
- ✅ **Core Functionality**: BAMON binary execution, configuration management

## Contributing

When adding new tests:

1. **Follow naming conventions**: `test_feature.bats`
2. **Add to appropriate category**: installation, commands, daemon, performance
3. **Update this README**: Document new test categories
4. **Test locally**: Ensure tests pass before committing
5. **Use helper functions**: Leverage existing test infrastructure
6. **Check current status**: Review known issues before adding new tests
