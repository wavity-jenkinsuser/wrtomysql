#!/usr/bin/env groovy
pipeline {
    agent any
    environment {
        COMMIT_ARRAY = 'Hi'
    }
    stages {
        stage('Build') {
            steps {
                sh 'echo "Hello, i\'m temp script."'
                sh 'echo "My var GIT_PREVIOUS_SUCCESSFUL_COMMIT is: ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}"'
                sh 'echo "My var GIT_COMMIT is: ${GIT_COMMIT}"'
                COMMIT_ARRAY= sh 'git rev-list ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}^..HEAD'
                echo "${env.COMMIT_ARRAY}"
                sh 'echo "Test: ${COMMIT_ARRAY[@]}"'
                mail bcc: 'someone@example.com', body: 'SOME-TEXT', cc: 'someone@example.com', from: '', replyTo: '', subject: 'DETECT ERROR', to: 'someone@example.com'
            }
        }
    }
}
