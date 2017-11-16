#!/usr/bin/env groovy
pipeline {
    agent any
    checkout([$class: 'GitSCM', branches: [[name: '**']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '8a5ae250-42f8-482a-ba21-af74658e34c2', url: 'https://github.com/Energy1190/wrtomysql']]])
    stages {
        stage('Build') {
            steps {
                sh 'chmod +x ${WORKSPACE}/remessage.sh && ${WORKSPACE}/remessage.sh'
                mail bcc: 'someone@example.com', body: 'SOME-TEXT', cc: 'someone@example.com', from: '', replyTo: '', subject: 'DETECT ERROR', to: 'someone@example.com'
            }
        }
    }
}
