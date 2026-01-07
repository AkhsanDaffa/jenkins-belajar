pipeline {
    agent any

    environment {
        // Ini adalah path DI DALAM container Jenkins
        // Yang sudah kita hubungkan ke folder Pi
        DEPLOY_DIR = '/var/project-kantor'
    }

    stages {
        stage('Deploy to Raspberry Pi') {
            steps {
                script {
                    echo "--- 1. Copy File ke Folder Deploy ---"
                    // Salin semua file dari workspace Jenkins ke folder bersama
                    // Menggunakan 'rsync' atau 'cp'
                    sh "cp -r . ${DEPLOY_DIR}"
                    
                    echo "--- 2. Eksekusi Docker Compose ---"
                    // Pindah konteks ke folder tersebut
                    dir("${DEPLOY_DIR}") {
                        // Perintah ini akan dijalankan oleh Docker Host (Pi)
                        // Karena kita share docker.sock
                        try {
                            sh 'docker compose down || true'
                            sh 'docker compose up -d --build --force-recreate'
                            sh 'docker compose ps'
                        } catch (Exception e) {
                            echo "Error saat deploy: ${e.getMessage()}"
                            currentBuild.result = 'FAILURE'
                        }
                    }
                }
            }
        }
    }
}