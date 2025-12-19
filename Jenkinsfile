pipeline {
    agent any

    environment {
        APP_NAME = "chat-app"
        APP_DIR  = "/opt/chat-app"
        NODE_BIN = "/home/unique/.nvm/versions/node/v24.12.0/bin"
        SSH_CRED = "aws-ec2-ssh"
        EC2_HOST = "unique@3.233.131.221"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build on Jenkins') {
            steps {
                sh '''
                    set -e
                    echo "===== NODE ====="
                    node -v
                    npm -v

                    echo "===== INSTALL DEPENDENCIES ====="
                    npm install
                '''
            }
        }

        stage('Deploy to AWS EC2') {
            steps {
                sshagent(credentials: ["${SSH_CRED}"]) {
                    sh '''
                        set -e

                        echo "===== COPY CODE TO EC2 ====="
                        rsync -avz --delete \
                          --exclude=.git \
                          --exclude=node_modules \
                          ./ ${EC2_HOST}:${APP_DIR}/

                        echo "===== START APP ON EC2 ====="
                        ssh -o StrictHostKeyChecking=no ${EC2_HOST} << EOF
                          set -e
                          export PATH=${NODE_BIN}:\$PATH
                          cd ${APP_DIR}

                          npm install

                          ${NODE_BIN}/pm2 delete ${APP_NAME} || true
                          ${NODE_BIN}/pm2 start app.js --name ${APP_NAME}
                        EOF
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ DEPLOYMENT SUCCESSFUL"
        }
        failure {
            echo "❌ DEPLOYMENT FAILED"
        }
    }
}
