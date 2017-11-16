#!/usr/bin/env groovy
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh 'chmod +x ${WORKSPACE}/remessage.sh && ${WORKSPACE}/remessage.sh'
            }
        }
    }
}
