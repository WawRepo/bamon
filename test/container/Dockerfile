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

# Copy only test scripts first
COPY test/ /app/test/

# Run setup script to install BATS and dependencies (before copying source code)
RUN /app/test/container/setup.sh

# Copy source code (this layer will be invalidated more frequently)
COPY . /app/

# Set default command
CMD ["/bin/bash"]
