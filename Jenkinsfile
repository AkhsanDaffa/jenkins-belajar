pipeline {
    agent any
    stages {
        stage('Build dari GitHub') {
            steps {
                echo 'Sedang memproses code dari GitHub...'
                sh 'docker build -t app-github:v1 .'
            }
        }
        stage('Jalankan Test') {
            steps {
                sh 'docker run --rm app-github:v1'
            }
        }
    }

    post {
        always {
            script {
                echo '=== MEMBERSIHKAN SAMPAH ==='
                sh 'docker rmi app-github:v1'

                sh 'docker image prune -f'
            }
        }
    }
}
