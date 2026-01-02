pipeline {
    agent any

    environment {
        VPS_IP       = '103.181.142.253'
        REGISTRY_URL = '103.181.142.253:5026'
        IMAGE_NAME   = 'app-github:v1'
        CONTAINER_NAME = 'website-saya'
    }

    stages {
        stage('Build Image') {
            steps {
                echo '=== BUILDING IMAGE ==='
                sh 'docker build -t ${REGISTRY_URL}/${IMAGE_NAME} .'
            }
        }

        stage('Push to VPS Registry') {
            steps {
                echo '=== UPLOADING TO VPS ==='
                sh "docker push ${REGISTRY_URL}/${IMAGE_NAME}"
            }
        }

        stage('Deploy to Production') {
            steps {
                echo '=== DEPLOYING TO LIVE SERVER ==='
                withCredentials([sshUserPrivateKey(credentialsId: 'vps-ssh-key', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                    script {
                        def remoteCmd = """
                            echo "--- 1. Login ke Registry ---"
                            # (Opsional karena insecure registry sudah di-whitelist, tapi aman untuk debug)
                            
                            echo "--- 2. Hapus Container Lama ---"
                            docker stop ${CONTAINER_NAME} || true
                            docker rm ${CONTAINER_NAME} || true
                            
                            echo "--- 3. Pull Image Baru ---"
                            docker pull ${REGISTRY_URL}/${IMAGE_NAME}
                            
                            echo "--- 4. Jalankan Website Baru ---"
                            # Kita jalankan di Port 80 biar bisa akses langsung tanpa ketik port
                            docker run -d --name ${CONTAINER_NAME} -p 8081:80 ${REGISTRY_URL}/${IMAGE_NAME}
                        """

                        sh "ssh -i $SSH_KEY -o StrictHostKeyChecking=no $SSH_USER@${VPS_IP} '${remoteCmd}'"
                    }
                }
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
