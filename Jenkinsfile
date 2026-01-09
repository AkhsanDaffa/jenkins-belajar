pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['Deploy Update Terbaru', 'Rollback ke Versi Lama'], description: 'Mau Deploy atau Rollback?')
        string(name: 'SPECIFIC_VERSION', defaultValue: '', description: 'KOSONGKAN jika Deploy Update Terbaru. ISI Hash Commit jika mau Rollback (Contoh: e47d9c6)')
    }

    environment {
        // IP Raspberry Pi & Port Registry Anda
        REGISTRY_URL   = '100.118.31.124:2612' 
        IMAGE_NAME     = 'web-kantor'
        CONTAINER_NAME = 'web-production'
        APP_PORT       = '8090'

        DISCORD_URL    = 'https://discord.com/api/webhooks/1459002890273296559/wUqWc7MlMbKhsplmz0Aeh3OzIxWZ6wP8jyYHjzSqhelImNX9pxl40iyKC_3nbf9BCuJy'
    }

    stages {
        stage('Setup Version') {
            steps {
                script {
                    // Logika Canggih: Pilih Versi Otomatis atau Manual
                    if (params.ACTION == 'Rollback ke Versi Lama' && params.SPECIFIC_VERSION != '') {
                        env.GIT_TAG = params.SPECIFIC_VERSION
                        echo "⏪ MODE ROLLBACK: Menggunakan versi lama -> ${env.GIT_TAG}"
                    } else {
                        // Ambil versi terbaru dari Git
                        env.GIT_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                        echo "🚀 MODE UPDATE: Menggunakan versi terbaru -> ${env.GIT_TAG}"
                    }
                }
            }
        }

    stages {
        stage('Quality Control') {
            steps {
                script {
                    echo "--- 🛡️ Menjalankan Automated Test ---"
                    // Jenkins menjalankan script test yang kita buat tadi
                    sh "./test_quality.sh"
                }
            }
        }

        stage('Set Dynamic Version') {
            steps {
                script {
                    env.GIT_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    
                    echo "--- Deployment untuk Versi: ${env.GIT_TAG} ---"
                }
            }
        }

        stage('Security Scan') {
            steps {
                script {
                    echo "--- 👮 Cek Virus & Celah Keamanan ---"
                    sh "docker run --rm aquasec/trivy image --timeout 20m --exit-code 1 --severity CRITICAL,HIGH --ignore-unfixed --insecure ${REGISTRY_URL}/${IMAGE_NAME}:${env.GIT_TAG}"
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

    post {
        success {
            script {
                // 1. Kirim Laporan Sukses ke Discord
                discordSend description: "✅ **Deploy Berhasil!**\nVersi: `${env.GIT_TAG}`\nWebsite: http://100.118.31.124:${APP_PORT}", 
                            footer: "Jenkins Raspberry Pi", 
                            link: env.BUILD_URL, 
                            result: currentBuild.currentResult, 
                            title: "🚀 Deployment Sukses: ${env.JOB_NAME}", 
                            webhookURL: env.DISCORD_URL

                // 2. Bersih-bersih (Maintenance)
                sh "docker image prune -f"
            }
        }
        failure {
            script {
                // Kirim Laporan Gagal (PENTING BIAR TAHU ERROR)
                discordSend description: "❌ **Deploy GAGAL!**\nMohon cek log console segera.", 
                            footer: "Jenkins Raspberry Pi", 
                            link: env.BUILD_URL, 
                            result: currentBuild.currentResult, 
                            title: "🚨 Deployment Error: ${env.JOB_NAME}", 
                            webhookURL: env.DISCORD_URL
            }
        }
    }
}
}