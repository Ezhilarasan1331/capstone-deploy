#!/bin/bash

# Define variables
IMAGE_NAME="capstoneimg"
IMAGE_TAG="latest"
DOCKERFILE_PATH="." # Path to your Dockerfile, usually the current directory

# Print a message
echo "Building Docker image ${IMAGE_NAME}:${IMAGE_TAG}..."

# Install Docker Compose if not already installed
if ! command -v docker-compose &> /dev/null
then
    echo "Docker Compose not found, installing..."
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Build the Docker image
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKERFILE_PATH}

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "Docker image ${IMAGE_NAME}:${IMAGE_TAG} built successfully."
else
    echo "Failed to build Docker image ${IMAGE_NAME}:${IMAGE_TAG}."
    exit 1
fi

# Run Docker Compose
echo "Starting Docker Compose..."
docker-compose up -d

# Check if Docker Compose was successful
if [ $? -eq 0 ]; then
    echo "Docker Compose started successfully."
else
    echo "Failed to start Docker Compose."
    exit 1
fi
