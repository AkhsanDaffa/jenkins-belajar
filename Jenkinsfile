pipeline {
    agent any

    // --- MENU RESTORAN (PARAMETER) ---
    parameters {
        choice(name: 'ACTION', choices: ['Deploy Update Terbaru', 'Rollback ke Versi Lama'], description: 'Pilih aksi yang mau dilakukan:')
        string(name: 'SPECIFIC_VERSION', defaultValue: '', description: 'KOSONGKAN jika Update Terbaru. ISI Hash Commit jika mau Rollback (Contoh: e47d9c6)')
    }

    environment {
        // --- KONFIGURASI SERVER ---
        REGISTRY_URL   = '100.118.31.124:2612' 
        IMAGE_NAME     = 'web-kantor'
        CONTAINER_NAME = 'web-production'
        APP_PORT       = '8090'
        
        // --- GANTI DENGAN URL DISCORD ANDA ---
        DISCORD_URL    = 'https://discord.com/api/webhooks/YOUR_WEBHOOK_URL_HERE' 
    }

    stages {
        // STAGE 1: TENTUKAN VERSI (OTOMATIS / MANUAL)
        stage('Setup Version') {
            steps {
                script {
                    // Logika: Cek apakah user mau Rollback atau Update
                    if (params.ACTION == 'Rollback ke Versi Lama' && params.SPECIFIC_VERSION != '') {
                        env.GIT_TAG = params.SPECIFIC_VERSION
                        echo "⏪ MODE ROLLBACK: Menggunakan versi lama -> ${env.GIT_TAG}"
                    } else {
                        // Default: Ambil versi terbaru dari Git
                        env.GIT_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                        echo "🚀 MODE UPDATE: Menggunakan versi terbaru -> ${env.GIT_TAG}"
                    }
                }
            }
        }

        // STAGE 2: TEST KODINGAN
        stage('Quality Control') {
            steps {
                script {
                    echo "--- 🛡️ 1. Cek Kualitas Code ---"
                    sh "./test_quality.sh"
                }
            }
        }

        // STAGE 3: SECURITY SCAN
        stage('Security Scan') {
            steps {
                script {
                    echo "--- 👮 2. Cek Virus & Celah Keamanan ---"
                    // Skip scan kalau Rollback (biar cepat & karena asumsinya versi lama sudah pernah dicek)
                    if (params.ACTION == 'Deploy Update Terbaru') {
                        sh "docker run --rm aquasec/trivy image --timeout 20m --exit-code 1 --severity CRITICAL,HIGH --ignore-unfixed --insecure ${REGISTRY_URL}/${IMAGE_NAME}:${env.GIT_TAG}"
                    } else {
                        echo "⏩ Skip Security Scan untuk Rollback."
                    }
                }
            }
        }

        // STAGE 4: DEPLOYMENT
        stage('Deploy from Registry') {
            steps {
                script {
                    echo "--- 🚚 3. Deployment Dimulai (${env.GIT_TAG}) ---"
                    
                    // Tarik image (penting untuk rollback jika image lokal sudah terhapus)
                    sh "docker pull ${REGISTRY_URL}/${IMAGE_NAME}:${env.GIT_TAG}"
                    
                    // Hapus container lama
                    sh "docker rm -f ${CONTAINER_NAME} || true"
                    
                    // Jalankan container baru
                    sh """
                        docker run -d \
                        --name ${CONTAINER_NAME} \
                        -p ${APP_PORT}:80 \
                        --restart always \
                        ${REGISTRY_URL}/${IMAGE_NAME}:${env.GIT_TAG}
                    """
                }
            }
        }
    }

    // STAGE 5: NOTIFIKASI
    post {
        success {
            script {
                discordSend description: "✅ **${params.ACTION} SUKSES!**\nVersi: `${env.GIT_TAG}`\nWebsite: http://100.118.31.124:${APP_PORT}", 
                            footer: "Jenkins Commander", 
                            link: env.BUILD_URL, 
                            result: currentBuild.currentResult, 
                            title: "🚀 Misi Selesai", 
                            webhookURL: env.DISCORD_URL
                
                // Bersih-bersih image sampah
                sh "docker image prune -f"
            }
        }
        failure {
            script {
                discordSend description: "❌ **Deploy GAGAL!**\nCek log Jenkins untuk detail error.", 
                            footer: "Jenkins Commander", 
                            link: env.BUILD_URL, 
                            result: currentBuild.currentResult, 
                            title: "🚨 Gagal", 
                            webhookURL: env.DISCORD_URL
            }
        }
    }
}