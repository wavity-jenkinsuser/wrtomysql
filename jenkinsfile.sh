#!/usr/bin/env groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'chmod +x ${WORKSPACE}/remessage.sh && ${WORKSPACE}/remessage.sh'
                mail bcc: 'someone@example.com', body: 'SOME-TEXT', cc: 'someone@example.com', from: '', replyTo: '', subject: 'DETECT ERROR', to: 'someone@example.com'
            }
        }
    }
}
