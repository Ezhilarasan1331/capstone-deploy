#!/bin/bash

set -e

# Define variables
IMAGE_NAME="capstoneimg"
IMAGE_TAG="latest"
DOCKERFILE_PATH="." # Path to your Dockerfile, usually the current directory
COMPOSE_FILE="docker-compose.yml"

# Print a meg
echo "Building Docker image ${IMAGE_NAME}:${IMAGE_TAG}..."

# Build the Docker image
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKERFILE_PATH}

# Check if the build was successful
if [ $? -ne 0 ]; then
    echo "Failed to build Docker image ${IMAGE_NAME}:${IMAGE_TAG}."
    exit 1
fi

# Run Docker Compose
echo "Starting Docker Compose..."
docker-compose -f ${COMPOSE_FILE} down --remove-orphans
docker-compose -f ${COMPOSE_FILE} up -d

# Check if Docker Compose was successful
if [ $? -ne 0 ]; then
    echo "Failed to start Docker Compose."
    exit 1
fi

echo "Docker Compose started successfully."
