pipeline {
    agent any

    environment {
        // IP Raspberry Pi & Port Registry Anda
        REGISTRY_URL   = '100.118.31.124:2612' 
        IMAGE_NAME     = 'web-kantor'
        CONTAINER_NAME = 'web-production'
        APP_PORT       = '8090'
    }

    stages {
        stage('Set Dynamic Version') {
            steps {
                script {
                    // MENGAMBIL 7 DIGIT PERTAMA DARI GIT COMMIT HASH
                    // Contoh hasil: "a1b2c3d"
                    env.GIT_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    
                    echo "--- Deployment untuk Versi: ${env.GIT_TAG} ---"
                }
            }
        }

        stage('Deploy from Registry') {
            steps {
                script {
                    // Menggunakan variabel ${GIT_TAG} yang didapat di stage sebelumnya
                    echo "--- 1. Pull Image: ${IMAGE_NAME}:${GIT_TAG} ---"
                    sh "docker pull ${REGISTRY_URL}/${IMAGE_NAME}:${GIT_TAG}"
                    
                    echo "--- 2. Cleanup Old Container ---"
                    sh "docker rm -f ${CONTAINER_NAME} || true"
                    
                    echo "--- 3. Run New Container ---"
                    sh """
                        docker run -d \
                        --name ${CONTAINER_NAME} \
                        -p ${APP_PORT}:80 \
                        --restart always \
                        ${REGISTRY_URL}/${IMAGE_NAME}:${GIT_TAG}
                    """
                }
            }
        }
    }
}