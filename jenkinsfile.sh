#!/usr/bin/env groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'echo "Hello, i\'m temp script."'
                sh 'echo "My var GIT_PREVIOUS_SUCCESSFUL_COMMIT is: ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}"'
                sh 'echo "My var GIT_COMMIT is: ${GIT_COMMIT}"'
                env.COMMIT_ARRAY= sh 'git rev-list ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}^..HEAD'
                sh 'echo "Test: ${env.COMMIT_ARRAY[@]}"'
                mail bcc: 'someone@example.com', body: 'SOME-TEXT', cc: 'someone@example.com', from: '', replyTo: '', subject: 'DETECT ERROR', to: 'someone@example.com'
            }
        }
    }
}
