pipeline {
    agent any
    stages {
        stage('Build dari GitHub') {
            steps {
                echo 'Sedang memproses code dari GitHub...'
                // Build image dari Dockerfile yang ada di folder ini
                sh 'docker build -t app-github:v1 .'
            }
        }
        stage('Jalankan Test') {
            steps {
                // Coba jalankan sebentar untuk tes
                sh 'docker run --rm app-github:v1'
            }
        }
    }
}
