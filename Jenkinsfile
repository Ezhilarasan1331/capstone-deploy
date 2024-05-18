pipeline {
  agent any

  environment {
    DOCKER_DEV_REPO = 'development' // Replace with your development Docker Hub repository name
    DOCKER_PROD_REPO = 'prod'        // Replace with your production Docker Hub repository name (private)
    DOCKERHUB_CREDENTIALS = credentials(docker-hub-user')
    DOCKER_HUB_USER = credentials('docker-hub-user')  // Jenkins credentials for Docker Hub username
    DOCKER_HUB_PASS = credentials('docker-hub-pass')  // Jenkins credentials for Docker Hub password
  }

  triggers {
    github(
      branches: ['dev', 'master'], // Trigger on pushes to both dev and master branch
      skipTag: true, // Don't trigger on tag pushes
      advancedNotifications: true // Enable detailed notifications
    )
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
        expression { // Build only on specific branch pushes
          return (env.BRANCH_NAME == 'dev') || (env.CHANGE_ORIGIN ==~ 'PR' && env.CHANGE_TARGET == 'master')
        }
      }
      steps {
        script {
          def imageName = env.BRANCH_NAME == 'dev' ? "${DOCKER_DEV_REPO}/your-image-name" : "${DOCKER_PROD_REPO}/capstoneimg"
          def dockerImage = docker.build(imageName)

          try {
            docker.withRegistry("https://registry.hub.docker.com", "${DOCKER_HUB_USER}:${DOCKER_HUB_PASS}") {
              dockerImage.push()
              if (env.BRANCH_NAME == 'dev') {
                dockerImage.push("${imageName}:latest") // Push latest tag only for dev branch
              }
            }
          } catch (Exception e) {
            error "Failed to push image: ${e.message}"
          }
        }
      }
    }
  }
}

