pipeline {
    agent any

    environment {
        EC2_USER = "unique"
        EC2_IP   = "3.233.131.221"
        APP_DIR  = "/opt/chat-app"
        NODE_BIN = "/home/unique/.nvm/versions/node/v24.12.0/bin"
        SSH_CRED = "aws-ec2-ssh"   // Jenkins Credential ID
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
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_IP} "whoami && hostname"
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
                          ./ ${EC2_USER}@${EC2_IP}:${APP_DIR}/

                        echo "===== START APP ON EC2 ====="
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_IP} << EOF
                          set -e
                          export PATH=${NODE_BIN}:\$PATH
                          cd ${APP_DIR}

                          echo "NODE:"
                          node -v
                          npm -v

                          pm2 delete chat-app || true
                          pm2 start app.js --name chat-app
                        EOF
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful"
        }
        failure {
            echo "❌ Deployment failed"
        }
    }
}
