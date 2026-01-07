pipeline {
    agent any

    environment {
        // Path folder "Bersama" di dalam container Jenkins
        // Pastikan ini sesuai dengan volume mapping di docker-compose.yml Anda
        DEPLOY_DIR = '/var/project-kantor'
    }

    stages {
        // Tahap 1: Approval (Opsional, biar sama kayak flow kemarin)
        stage('Manual Approval') {
            steps {
                script {
                    timeout(time: 1, unit: 'HOURS') {
                        input message: 'Deploy ke Raspberry Pi?', ok: 'Gas!'
                    }
                }
            }
        }

        // Tahap 2: Deploy Lokal
        stage('Deploy to Raspberry Pi') {
            steps {
                script {
                    echo "--- 1. Copy File dari Workspace ke Folder Project ---"
                    // Menyalin file kodingan terbaru ke folder yang dimounting ke Pi
                    sh "cp -r . ${DEPLOY_DIR}"
                    
                    echo "--- 2. Eksekusi Docker Compose ---"
                    // Masuk ke folder itu, lalu perintahkan Docker
                    dir("${DEPLOY_DIR}") {
                        // Matikan container lama & nyalakan yang baru
                        // '|| true' agar tidak error kalau container belum ada
                        sh 'docker compose down || true' 
                        sh 'docker compose up -d --build --force-recreate'
                        sh 'docker compose ps'
                    }
                }
            }
        }
    }
}