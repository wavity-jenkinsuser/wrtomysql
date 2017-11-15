pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh 'echo "Hello!" && ls -la ./'
            }
        }
    }
}
