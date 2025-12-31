pipeline {
    agent any

    environment {
        REGISTRY_URL = '103.181.142.253:5026'
        IMAGE_NAME   = 'app-github:v1'
    }

    stages {
        stage('Build Image') {
            steps {
                echo '=== BUILDING IMAGE ==='
                sh 'docker build -t ${REGISTRY_URL}/${IMAGE_NAME} .'
            }
        }
        stage('Test Run') {
            steps {
                sh 'docker run --rm ${REGISTRY_URL}/${IMAGE_NAME}'
            }
        }

        stage('Push to VPS') {
            steps {
                echo '=== UPLOADING TO VPS ==='
                sh 'docker push ${REGISTRY_URL}/${IMAGE_NAME}'
            }
        }
    }

    post {
        always {
            script {
                echo '=== BERSIH-BERSIH ==='
                sh 'docker rmi ${REGISTRY_URL}/${IMAGE_NAME} || true'
                sh 'docker image prune -f'
            }
        }
    }
}
