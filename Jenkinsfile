pipeline {
    agent any
    
    environment {
        DOCKER_DEV_REPO = 'dev'  // Replace with your development Docker Hub repository name
        DOCKER_PROD_REPO = 'prod'  // Replace with your production Docker Hub repository name
        DOCKER_HUB_CREDENTIALS = 'ezhilarasan1331-dockerhup'  // Jenkins credential ID for Docker Hub
        COMPOSE_FILE = "docker-compose.yml"
        IMAGE_NAME = "capstoneimg"
        IMAGE_TAG = "latest"
        DOCKERFILE_PATH = "." // Path to your Dockerfile, usually the current directory
	EC2_SSH_CREDENTIALS = 'ec2-ssh-key' // Jenkins credential ID for EC2 SSH key
        EC2_HOST = 'ubuntu@35.154.116.78' // Replace with your EC2 instance's public IP address
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
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    def branchName = env.BRANCH_NAME ?: env.GIT_BRANCH ?: 'unknown'
                    
                    echo "Detected branch: ${branchName}"
                    
                    // Remove 'origin/' prefix if present
                    branchName = branchName.replaceAll('^origin/', '')
                    
                    echo "Branch after removing prefix: ${branchName}"
                    
                    def DOCKER_HUB_REPO
                    
                    // Determine the Docker Hub repo based on the branch
                    if (branchName == 'dev') {
                        DOCKER_HUB_REPO = DOCKER_DEV_REPO
                    } else if (branchName == 'master') {
                        DOCKER_HUB_REPO = DOCKER_PROD_REPO
                    } else {
                        error "Branch ${branchName} is not supported for deployment."
                    }
                    
                    echo "Using Docker Hub repository: ${DOCKER_HUB_REPO}"
                    
                    // Tag and push the Docker image to Docker Hub
                    withCredentials([usernamePassword(credentialsId: DOCKER_HUB_CREDENTIALS, usernameVariable: 'DOCKER_HUB_USER', passwordVariable: 'DOCKER_HUB_PASSWORD')]) {
                        def dockerLogin = "docker login -u ${DOCKER_HUB_USER} -p ${DOCKER_HUB_PASSWORD}"
                        def dockerTag = "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:${IMAGE_TAG}"
                        def dockerPush = "docker push ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:${IMAGE_TAG}"
                        
                        echo "Executing Docker login..."
                        sh "${dockerLogin}"
                        
                        echo "Tagging Docker image..."
                        sh "${dockerTag}"
                        
                        echo "Pushing Docker image to ${DOCKER_HUB_REPO}..."
                        sh "${dockerPush}"
                    }
                }
            }
        }
		
		
		     stage('Deploy to AWS EC2') {
            steps {
                script {
                    echo "Deploying to AWS EC2..."
                    // SSH to the EC2 instance and pull the Docker image, then run it
                    sshagent(credentials: [EC2_SSH_CREDENTIALS]) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ${EC2_HOST} << EOF
                                docker login -u ${env.DOCKER_HUB_USER} -p ${env.DOCKER_HUB_PASSWORD}
                                docker pull ${env.DOCKER_HUB_USER}/${env.DOCKER_PROD_REPO}:${env.IMAGE_TAG}
                                docker stop ${env.IMAGE_NAME} || true
                                docker rm ${env.IMAGE_NAME} || true
                                docker run -d --name ${env.IMAGE_NAME} -p 80:80 ${env.DOCKER_HUB_USER}/${env.DOCKER_PROD_REPO}:${env.IMAGE_TAG}
                            EOF
                        """
                    }
                }
            }
        }
		
    }

    post {
        always {
            // Clean up Docker the  images after build
            cleanWs()
        }
    }
}
