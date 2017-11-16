#!/usr/bin/env groovy
pipeline {
    agent any
    environment {
        COMMIT_ARRAY = sh 'git rev-list ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}^..HEAD'
    }
    stages {
        stage('Test message') {
            steps {
                sh 'printenv'
                script {
                    FILENAME = sh(returnStdout: true, script:'git rev-list ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}^..HEAD')
                    BADLIST = loop_with_preceding_sh(FILENAME)
                    BOOL = loop_bad_message(BADLIST)
                    echo "hi ${BOOL}"
                }
            }
        }
    }
}

def loop_with_preceding_sh(list) {
    def badMessage = []
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
    return badMessage
}

def loop_bad_message(list) {
    if (0 < list.size()) { 
        return true
    } else {
        return false
    }
}
