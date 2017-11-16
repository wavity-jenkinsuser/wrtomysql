#!/usr/bin/env groovy
pipeline {
    agent any
    environment {
        COMMIT_ARRAY = sh 'git rev-list ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}^..HEAD'
    }
    stages {
        stage('Test message') {
            steps {
                script {
                    FILENAME = sh(returnStdout: true, script:'git rev-list ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}^..HEAD')
                    loop_with_preceding_sh(FILENAME)
                    loop_bad_message()
                }
            }
        }
    }
}

def badMessage = [:]
def loop_with_preceding_sh(list) {
    array = list.split()
    for (int i = 0; i < array.size(); i++) {
        message = sh(returnStdout: true, script: "git log --format=%B -n 1 ${array[i]}")
        sh "echo Working for ${array[i]}"
        if (message =~ /(.*)running(.*)/) {
            echo "Good news"
        } else {
            echo "Bad news"
            badMessage.push(array[i])
        }
    }
}

def loop_with_preceding_sh() {
    for (int i = 0; i < badMessage.size(); i++) {
        echo "hi Bad Message badMessage[i]"
    }
}
