#!/bin/bash

set -e

DOCKER_HUB_REPO=""
BRANCH_NAME="${GIT_BRANCH:-$BRANCH_NAME}"

echo "Detected branch: ${BRANCH_NAME}"

# Remove 'origin/' prefix if present
if [[ "$BRANCH_NAME" == "origin/"* ]]; then
    BRANCH_NAME="${BRANCH_NAME/origin\//}"
fi

echo "Branch after removing prefix: ${BRANCH_NAME}"

# Determine the Docker Hub repo based on the branch
if [[ "$BRANCH_NAME" == "dev" ]]; then
    DOCKER_HUB_REPO="$DOCKER_DEV_REPO"
elif [[ "$BRANCH_NAME" == "master" ]]; then
    DOCKER_HUB_REPO="$DOCKER_PROD_REPO"
else
    echo "Branch ${BRANCH_NAME} is not supported for deployment."
    exit 1
fi

echo "Using Docker Hub repository: ${DOCKER_HUB_REPO}"
# Docker login and push
docker_login() {
    echo "Executing Docker login..."
    docker login -u "$DOCKER_HUB_USER" -p "$DOCKER_HUB_PASSWORD"
}

tag_and_push_image() {
    local IMAGE_NAME="capstoneimg"
    local IMAGE_TAG="latest"

    echo "Tagging Docker image..."
    docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:${IMAGE_TAG}"

    echo "Pushing Docker image to ${DOCKER_HUB_REPO}..."
    docker push "${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:${IMAGE_TAG}"
}

# Main script execution
docker_login
tag_and_push_image
<<<<<<< HEAD

=======
>>>>>>> origin/dev
