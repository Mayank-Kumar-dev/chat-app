pipeline {
    agent any

    environment {
        APP_NAME = "chat-app"
        APP_DIR  = "/opt/chat-app"
        NODE_BIN = "/home/unique/.nvm/versions/node/v24.12.0/bin"
        EC2_USER = "unique"
        EC2_HOST = "3.233.131.221"
        SSH_CRED = "aws-ec2-ssh"
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
                    echo "===== NODE VERSION ====="
                    node -v
                    npm -v

                    echo "===== INSTALL DEPENDENCIES ====="
                    npm install
                '''
            }
        }

        stage('Test SSH Connection') {
            steps {
                sshagent(credentials: ["${SSH_CRED}"]) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} "whoami && hostname"
                    '''
                }
            }
        }

        stage('Deploy to AWS EC2') {
            steps {
                sshagent(credentials: ["${SSH_CRED}"]) {
                    sh '''
                        echo "===== COPY CODE TO EC2 ====="
                        rsync -avz --delete \
                          --exclude=.git \
                          --exclude=node_modules \
                          ./ ${EC2_USER}@${EC2_HOST}:${APP_DIR}/

                        echo "===== START APP ON EC2 ====="
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} << EOF
                          set -e
                          export PATH=${NODE_BIN}:\$PATH
                          cd ${APP_DIR}

                          npm install

                          pm2 delete ${APP_NAME} || true
                          pm2 start app.js --name ${APP_NAME}
                        EOF
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment completed successfully"
        }
        failure {
            echo "❌ Deployment failed"
        }
    }
}
