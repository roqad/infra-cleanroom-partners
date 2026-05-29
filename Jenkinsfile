pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {
        stage("Checkout sources") {
            steps {
                checkout scm
            }
        }

        stage('Validate') {
            agent {
                docker {
                    reuseNode true
                    image 'docker.int.roqad.pl/infra-docker-tf:v1.2.2'
                }
            }

            steps {
                ansiColor('xterm') {
                    sh 'tofu init -backend=false'
                    sh 'tofu validate'
                }
            }
        }
    }
}
