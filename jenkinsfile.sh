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
                    COMMITLIST = sh(returnStdout: true, script:'git rev-list ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}^..HEAD')
                    BADLIST = loop_with_preceding_sh(COMMITLIST)
                    BOOL = loop_bad_message(BADLIST)
                    if (BOOL) {
                        loop_mail_send(BADLIST)
                    }
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
        sh "echo Working for ${array[i]} in ${GIT_BRANCH} wtere message ${message}"
        if (message =~ /update/) {
            echo "Good news"
        } else {
            echo "Bad news"
            badMessage.push("${array[i]}")
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

def loop_mail_send(list) {
    for (int i = 0; i < list.size(); i++) {
        autor = sh(returnStdout: true, script: "git log --format=%ae -n 1 ${list[i]}")
        autort = autor.trim()
        message = sh(returnStdout: true, script: "git log --format=%B -n 1 ${list[i]}")
        echo "Hello, ${autort}!  We have problems in commit ${list[i]} with a message: ${message}"
        mail bcc: "${autort}", body: "Hello, ${autort}! We have problems in commit ${list[i]} with a message: ${message}", cc: "${autort}", from: '', replyTo: '', subject: 'Bad message in your commit ${list[i]}', to: "${autort}"
    }
}
