#!/usr/bin/env groovy
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh 'ls -la ${WORKSPACE} && ${WORKSPACE}/remessage.sh'
            }
        }
    }
}
