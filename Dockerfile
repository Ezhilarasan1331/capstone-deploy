# Use the official Nginx image from Docker Hub
FROM nginx:alpine
# Copy static website files from the host to the container
COPY . /usr/share/nginx/html/

