pipeline {
    agent any
    
    environment {
        DOCKER_DEV_REPO = 'development'  // Replace with your development Docker Hub repository name
        DOCKER_PROD_REPO = 'prod'  // Replace with your production Docker Hub repository name
        DOCKER_HUB_CREDENTIALS = credentials('ezhilarasan1331-dockerhup')  // Jenkins credential ID for Docker Hub
        COMPOSE_FILE = "docker-compose.yml"
    }
    
    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from the GitHub repository
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                script {
                    // Define variables
                    def IMAGE_NAME = "capstoneimg"
                    def IMAGE_TAG = "latest"
                    def DOCKERFILE_PATH = "." // Path to your Dockerfile, usually the current directory
                    
                    // Print a message
                    echo "Building Docker image ${IMAGE_NAME}:${IMAGE_TAG}..."
                    
                    // Build the Docker image
                    sh """
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKERFILE_PATH}
                    """
                    
                    // Check if the build was successful
                    def buildStatus = sh(script: "docker images -q ${IMAGE_NAME}:${IMAGE_TAG}", returnStatus: true)
                    if (buildStatus == 0) {
                        echo "Docker image ${IMAGE_NAME}:${IMAGE_TAG} built successfully."
                    } else {
                        error "Failed to build Docker image ${IMAGE_NAME}:${IMAGE_TAG}."
                    }
                    
                    // Run Docker Compose
                    echo "Starting Docker Compose..."
                    sh """
                        docker-compose up -d
                    """
                    
                    // Check if Docker Compose was successful
                    def composeStatus = sh(script: "docker-compose ps", returnStatus: true)
                    if (composeStatus == 0) {
                        echo "Docker Compose started successfully."
                    } else {
                        error "Failed to start Docker Compose."
                    }
                }
            }
        }
        
        stage(' Docker Compose') {
            steps {
                script {
                    // Run Docker Compose
                    echo "Starting Docker Compose..."
                    sh "docker-compose -f ${COMPOSE_FILE} down --remove-orphans"
                    sh "docker-compose -f ${COMPOSE_FILE} up -d"
                    
                    // Check if Docker Compose was successful
                    def composeStatus = sh(script: "docker-compose -f ${COMPOSE_FILE} ps", returnStatus: true)
                    if (composeStatus == 0) {
                        echo "Docker Compose started successfully."
                    } else {
                        error "Failed to start Docker Compose."
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Clean up Docker images after build
            cleanWs()
            // Optionally, you can perform additional cleanup or notifications here
        }
    }
}
