#!/usr/bin/env bash
# Interactive BAMON setup script
# This script sets up BAMON with a test configuration for interactive testing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Setting up BAMON for Interactive Testing${NC}"
echo "=============================================="

# Install BAMON
echo -e "${YELLOW}📦 Installing BAMON...${NC}"
mkdir -p "/home/testuser/.local/bin"
cp /app/bamon "/home/testuser/.local/bin/"
chmod +x "/home/testuser/.local/bin/bamon"

# Copy library files
echo -e "${YELLOW}📚 Installing library files...${NC}"
mkdir -p "/home/testuser/.local/bin/lib"
cp /app/src/lib/*.sh "/home/testuser/.local/bin/lib/"
chmod +x "/home/testuser/.local/bin/lib/"*.sh

# Add to PATH
echo -e "${YELLOW}🛤️  Adding BAMON to PATH...${NC}"
export PATH="/home/testuser/.local/bin:$PATH"
echo 'export PATH="/home/testuser/.local/bin:$PATH"' >> "/home/testuser/.bashrc"

# Create test configuration
echo -e "${YELLOW}⚙️  Creating test configuration...${NC}"
mkdir -p "/home/testuser/.config/bamon"

cat > "/home/testuser/.config/bamon/config.yaml" << 'EOF'
daemon:
  default_interval: 300
  log_file: "/tmp/bamon.log"
  pid_file: "/tmp/bamon.pid"
  max_concurrent: 3

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
  - name: "health_check"
    command: echo 'Health check OK'
    interval: 60
    enabled: true
    description: "Basic health check script"
  
  - name: "disk_usage"
    command: df -h / | tail -n 1
    interval: 300
    enabled: true
    description: "Check disk usage"
  
  - name: "github_status"
    command: "curl -s https://www.githubstatus.com/api/v2/status.json | jq -r '.status.description'"
    interval: 600
    enabled: false
    description: "Check GitHub status"
EOF

# Create some test scripts
echo -e "${YELLOW}📝 Creating test scripts...${NC}"
mkdir -p "/home/testuser/test-scripts"

cat > "/home/testuser/test-scripts/simple_test.sh" << 'EOF'
#!/bin/bash
echo "Simple test script executed at $(date)"
echo "Current user: $(whoami)"
echo "Current directory: $(pwd)"
EOF

cat > "/home/testuser/test-scripts/error_test.sh" << 'EOF'
#!/bin/bash
echo "This script will fail"
exit 1
EOF

cat > "/home/testuser/test-scripts/long_running.sh" << 'EOF'
#!/bin/bash
echo "Starting long running script..."
for i in {1..5}; do
    echo "Step $i/5"
    sleep 2
done
echo "Long running script completed"
EOF

chmod +x "/home/testuser/test-scripts/"*.sh

# Verify installation
echo -e "${GREEN}✅ Verifying BAMON installation...${NC}"
if command -v bamon >/dev/null 2>&1; then
    echo -e "${GREEN}✅ BAMON is installed and available${NC}"
    bamon --version 2>/dev/null || echo "BAMON binary is available"
else
    echo -e "${RED}❌ BAMON installation failed${NC}"
    exit 1
fi

# Show configuration
echo -e "${GREEN}📋 Current BAMON configuration:${NC}"
bamon config show --pretty

echo ""
echo -e "${BLUE}🎉 Interactive BAMON Environment Ready!${NC}"
echo "=============================================="
echo ""
echo -e "${YELLOW}Available commands:${NC}"
echo "  bamon --help                    # Show help"
echo "  bamon status                    # Show status"
echo "  bamon list                      # List scripts"
echo "  bamon add <name> --command <cmd> # Add new script"
echo "  bamon now                       # Execute all scripts"
echo "  bamon start --daemon            # Start daemon"
echo "  bamon stop                      # Stop daemon"
echo "  bamon performance               # Show performance metrics"
echo ""
echo -e "${YELLOW}Test scripts available in ~/test-scripts/:${NC}"
echo "  ~/test-scripts/simple_test.sh   # Simple test script"
echo "  ~/test-scripts/error_test.sh    # Script that fails"
echo "  ~/test-scripts/long_running.sh  # Long running script"
echo ""
echo -e "${YELLOW}Example usage:${NC}"
echo "  bamon add test_script --command '~/test-scripts/simple_test.sh'"
echo "  bamon now --name test_script"
echo "  bamon start --daemon"
echo "  bamon status --json"
echo ""
echo -e "${GREEN}Happy testing! 🚀${NC}"
