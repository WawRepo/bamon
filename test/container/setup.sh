#!/usr/bin/env bash
# test/container/setup.sh

set -e

echo "Setting up BAMON test environment..."

# Install BATS and dependencies
echo "Installing BATS testing framework..."
git clone https://github.com/bats-core/bats-core.git
cd bats-core
./install.sh /usr/local
cd ..
rm -rf bats-core

# Install BATS support libraries
echo "Installing BATS support libraries..."
git clone https://github.com/bats-core/bats-support.git /usr/local/lib/bats-support
git clone https://github.com/bats-core/bats-assert.git /usr/local/lib/bats-assert

# Install required dependencies for bamon
echo "Installing BAMON dependencies..."
apt-get update
apt-get install -y bash curl jq bc

# Install yq
echo "Installing yq..."
curl -sL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/local/bin/yq
chmod +x /usr/local/bin/yq

# Install timeout (GNU coreutils)
apt-get install -y coreutils

# BAMON binary is assumed to exist in /app/bamon
echo "BAMON binary will be used from /app/bamon"

# Verify installations
echo "Verifying installations..."
bash --version | grep "version 4" || echo "Warning: Bash 4.0+ recommended"
curl --version | head -1
jq --version
yq --version
timeout --version | head -1

echo "Test environment setup complete!"
