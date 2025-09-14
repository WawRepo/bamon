FROM ubuntu:latest

# Install minimal dependencies for testing
RUN apt-get update && apt-get install -y \
    curl \
    git \
    sudo \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create test user with sudo access
RUN useradd -m testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/testuser

# Set working directory
WORKDIR /app

# Copy test scripts and source code
COPY test/ /app/test/
COPY . /app/

# Run setup script to install BATS and dependencies
RUN /app/test/container/setup.sh

# Set default command
CMD ["/bin/bash"]
