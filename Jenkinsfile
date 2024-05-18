pipeline {
    agent any
    
    environment {
        DOCKER_DEV_REPO = 'development'  // Replace with your development Docker Hub repository name
        DOCKER_PROD_REPO = 'prod'  // Replace with your production Docker Hub repository name
        DOCKER_HUB_CREDENTIALS = credentials('ezhilarasan1331-dockerhup')  // Jenkins credential ID for Docker Hub
        COMPOSE_FILE = "docker-compose.yml"
        IMAGE_NAME = "capstoneimg"
        IMAGE_TAG = "latest"
        DOCKERFILE_PATH = "." // Path to your Dockerfile, usually the current directory
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from the GitHub repository
                checkout scm
            }
        }
        
        stage('Build and Docker Compose') {
            steps {
                script {
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
        
           stage('Deploy') {
            steps {
                script {
                    def DOCKER_HUB_REPO
                    def branchName = env.GIT_BRANCH ?: env.BRANCH_NAME ?: 'unknown'
                    
                    // Determine the Docker Hub repo based on the branch
                    if (branchName == 'dev') {
                        DOCKER_HUB_REPO = DOCKER_DEV_REPO
                    } else if (branchName == 'master') {
                        DOCKER_HUB_REPO = DOCKER_PROD_REPO
                    } else {
                        error "Branch ${branchName} is not supported for deployment."
                    }
                    
                    // Tag and push the Docker image to Docker Hub
                    withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: DOCKER_HUB_CREDENTIALS, usernameVariable: 'DOCKER_HUB_USER', passwordVariable: 'DOCKER_HUB_PASSWORD']]) {
                        def dockerLogin = "docker login -u ${DOCKER_HUB_USER} -p ${DOCKER_HUB_PASSWORD}"
                        def dockerTag = "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_HUB_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
                        def dockerPush = "docker push ${DOCKER_HUB_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
                        
                        // Execute docker login, tag, and push commands
                        sh "${dockerLogin} && ${dockerTag} && ${dockerPush}"
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Clean up Docker images after build
            cleanWs()
        }
    }
}
