pipeline {
    agent any
    
    environment {
        DOCKER_DEV_REPO = 'development'  // Replace with your development Docker Hub repository name
        DOCKER_PROD_REPO = 'prod'  // Replace with your production Docker Hub repository name
        DOCKER_HUB_USER = credentials('docker-hub-user')  // Jenkins credentials for Docker Hub username
        DOCKER_HUB_PASS = credentials('docker-hub-pass')  // Jenkins credentials for Docker Hub password
    }
    
    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from the GitHub repository
                checkout scm
            }
        }
        
        stage('Build and Push Docker Image') {
            when {
                anyOf {
                    branch 'dev'
                    branch 'master'
                }
            }
            steps {
                script {
                    def dockerImage
                    def dockerRepo
                    
                    if (env.BRANCH_NAME == 'dev') {
                        dockerImage = docker.build("${DOCKER_DEV_REPO}/your-image-name")
                        dockerRepo = "${DOCKER_DEV_REPO}"
                    } else if (env.BRANCH_NAME == 'master') {
                        dockerImage = docker.build("${DOCKER_PROD_REPO}/your-image-name")
                        dockerRepo = "${DOCKER_PROD_REPO}"
                    } else {
                        error "Branch not supported for Docker build"
                    }
                    
                    // Push the Docker image
                    docker.withRegistry("https://registry.hub.docker.com", "${DOCKER_HUB_USER}:${DOCKER_HUB_PASS}") {
                        dockerImage.push()
                    }
                    
                    // Tag and push latest
                    docker.withRegistry("https://registry.hub.docker.com", "${DOCKER_HUB_USER}:${DOCKER_HUB_PASS}") {
                        dockerImage.push("${dockerRepo}/your-image-name:latest")
                    }
                }
            }
        }
    }
}
