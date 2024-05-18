# Use the official Nginx image from Docker Hub
FROM nginx:alpine
# Copy static website files from the host to the container
COPY . /usr/share/nginx/html/
# Use an official Docker image as a parent image
FROM docker:latest

# Install Docker Compose
RUN apk add --no-cache curl \
    && curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Verify installation
RUN docker --version && docker-compose --version
