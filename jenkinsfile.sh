#!/usr/bin/env groovy
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh 'git log -n 1 --pretty=format:"%h"'
            }
        }
    }
}
