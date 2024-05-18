pipeline {
    agent any {
        docker {
            image 'docker:latest' // Use a Docker image that has Docker installed
            args '-v /var/run/docker.sock:/var/run/docker.sock' // Mount Docker socket
        }
    }
    
    environment {
        DOCKER_DEV_REPO = 'development'  // Replace with your development Docker Hub repository name
        DOCKER_PROD_REPO = 'prod'  // Replace with your production Docker Hub repository name
        DOCKER_HUB_CREDENTIALS = credentials('ezhilarasan1331-dockerhup')  // Jenkins credential ID for Docker Hub
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
                    // Make the build.sh file executable
                    sh 'chmod +x build.sh'
                    
                    // Execute the build.sh script
                    sh './build.sh'
                }
            }
        }
        
        stage('Deploy with Docker Compose') {
            steps {
                script {
                    // Assuming docker-compose.yml is in the root directory of the repo
                    sh 'docker-compose down'
                    sh 'docker-compose up -d'
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

