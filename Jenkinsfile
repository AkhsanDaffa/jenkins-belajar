pipeline {
    agent any

    environment {
        // IP Raspberry Pi dan Port Registry (Sesuai yang anda berhasil push tadi)
        REGISTRY_IP = '100.118.31.124:2612' 
        IMAGE_NAME  = 'web-kantor'
        TAG         = 'v-test' // Nanti bisa kita bikin otomatis, sekarang hardcode dulu
        
        // Nama Container Website yang akan jalan
        CONTAINER_NAME = 'website-kantor-production'
        APP_PORT       = '8090' // Port website yang bisa dibuka di browser
    }

    stages {
        stage('Deploy from Local Registry') {
            steps {
                script {
                    echo "--- 1. Pull Image dari Gudang Lokal ---"
                    // Jenkins menarik image dari Registry yang ada di sebelahnya
                    sh "docker pull ${REGISTRY_IP}/${IMAGE_NAME}:${TAG}"
                    
                    echo "--- 2. Bersihkan Container Lama ---"
                    // Hapus container lama biar tidak bentrok nama
                    // '|| true' agar tidak error kalau ini deployment pertama
                    sh "docker rm -f ${CONTAINER_NAME} || true"
                    
                    echo "--- 3. Jalankan Website ---"
                    // Run container baru menggunakan image dari registry lokal
                    sh """
                        docker run -d \
                        --name ${CONTAINER_NAME} \
                        -p ${APP_PORT}:80 \
                        --restart always \
                        ${REGISTRY_IP}/${IMAGE_NAME}:${TAG}
                    """
                }
            }
        }
        
        stage('Health Check') {
            steps {
                // Pastikan container benar-benar hidup
                sh "docker ps | grep ${CONTAINER_NAME}"
                echo "Website berhasil dideploy di port ${APP_PORT}!"
            }
        }
    }
}