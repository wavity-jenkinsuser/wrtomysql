#!/usr/bin/env groovy
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', 
                branches: [[name: '*/*']], 
                doGenerateSubmoduleConfigurations: false, 
                extensions: [], 
                submoduleCfg: [], 
                userRemoteConfigs: [[credentialsId: '8a5ae250-42f8-482a-ba21-af74658e34c2', url: 'https://github.com/Energy1190/wrtomysql']]
                ])
            }
        }
        stage('Test message') {
            steps {
                script {
                    if (GIT_PREVIOUS_SUCCESSFUL_COMMIT) {
                        COMMITLIST = sh(returnStdout: true, script:'git rev-list ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}^..HEAD')
                        BADLIST = loop_with_preceding_sh(COMMITLIST)
                        BOOL = loop_bad_message(BADLIST)
                    }
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
        if (message =~ /^WCP-[\d]{4}.*/) {
//          echo "Good news, everyone"
        } else {
//          echo "Bad news, everyone"
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
//      echo "Hello, ${autort}!  We have problems in commit ${list[i]} with a message: ${message}"
//      adminmail = "example@domain.com"
//      mail bcc: "${adminmail}", body: "Hello, ${adminmail}"! One man ${autort} left a bad commit ${list[i]} with a message: ${message}", cc: "${adminmail}", from: '', replyTo: '', subject: 'Bad message in commit ${list[i]}', to: "${adminmail}"  
        mail bcc: "${autort}", body: "Hello, ${autort}! We have problems in commit ${list[i]} with a message: ${message}", cc: "${autort}", from: '', replyTo: '', subject: 'Bad message in your commit ${list[i]}', to: "${autort}"
    }
}
