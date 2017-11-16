#!/usr/bin/env groovy
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh 'ls -la / && remessage.sh'
            }
        }
    }
}
