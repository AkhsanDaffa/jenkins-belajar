pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['Deploy Update Terbaru', 'Rollback ke Versi Lama'], description: 'Pilih aksi yang mau dilakukan:')
        string(name: 'SPECIFIC_VERSION', defaultValue: '', description: 'KOSONGKAN jika Update Terbaru. ISI Hash Commit jika mau Rollback (Contoh: e47d9c6)')
    }

    environment {
        REGISTRY_URL   = '100.118.31.124:2612' 
        IMAGE_NAME     = 'web-kantor'
        CONTAINER_NAME = 'web-production'
        APP_PORT       = '8090'
        
        // PASTATIKAN URL DISCORD INI BENAR
        DISCORD_URL    = 'https://discord.com/api/webhooks/1459002890273296559/wUqWc7MlMbKhsplmz0Aeh3OzIxWZ6wP8jyYHjzSqhelImNX9pxl40iyKC_3nbf9BCuJy' 
    }

    stages {
        stage('Setup Version') {
            steps {
                script {
                    if (params.ACTION == 'Rollback ke Versi Lama' && params.SPECIFIC_VERSION != '') {
                        env.GIT_TAG = params.SPECIFIC_VERSION
                        echo "⏪ MODE ROLLBACK: Menggunakan versi lama -> ${env.GIT_TAG}"
                    } else {
                        env.GIT_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                        echo "🚀 MODE UPDATE: Menggunakan versi terbaru -> ${env.GIT_TAG}"
                    }
                }
            }
        }

        stage('Quality Control') {
            steps {
                script {
                    echo "--- 🛡️ 1. Cek Kualitas Code ---"
                    sh "./test_quality.sh"
                }
            }
        }

        stage('Security Scan') {
            steps {
                script {
                    echo "--- 👮 2. Cek Virus & Celah Keamanan ---"
                    if (params.ACTION == 'Deploy Update Terbaru') {
                        // Menggunakan timeout agar tidak hang
                        sh "docker run --rm aquasec/trivy image --timeout 20m --exit-code 1 --severity CRITICAL,HIGH --ignore-unfixed --insecure ${REGISTRY_URL}/${IMAGE_NAME}:${env.GIT_TAG}"
                    } else {
                        echo "⏩ Skip Security Scan untuk Rollback."
                    }
                }
            }
        }

        stage('Deploy from Registry') {
            steps {
                script {
                    echo "--- 🚚 3. Deployment Dimulai (${env.GIT_TAG}) ---"
                    
                    // Pull image dulu untuk memastikan file ada (terutama saat rollback)
                    sh "docker pull ${REGISTRY_URL}/${IMAGE_NAME}:${env.GIT_TAG}"
                    
                    // Hapus container lama jika ada
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

    post {
        success {
            script {
                discordSend description: "✅ **${params.ACTION} SUKSES!**\nVersi: `${env.GIT_TAG}`\nWebsite: http://100.118.31.124:${APP_PORT}", 
                            footer: "Jenkins Commander", 
                            link: env.BUILD_URL, 
                            result: currentBuild.currentResult, 
                            title: "🚀 Misi Selesai", 
                            webhookURL: env.DISCORD_URL
                
                // Bersihkan image sampah agar hemat storage
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