pipeline {
    agent any

    environment {
        EC2_USER = "unique"
        EC2_HOST = "3.233.131.221"
        APP_DIR  = "/opt/chat-app"
        NODE_BIN = "/home/unique/.nvm/versions/node/v24.12.0/bin"
        APP_NAME = "chat-app"
        SSH_CRED = "aws-ec2-ssh"   // Jenkins SSH credential ID
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
                sshagent(credentials: [SSH_CRED]) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} "whoami && hostname"
                    '''
                }
            }
        }

        stage('Deploy to AWS EC2') {
            steps {
                sshagent(credentials: [SSH_CRED]) {
                    sh '''
                        set -e

                        echo "===== SYNC CODE TO EC2 ====="
                        rsync -avz \
                          --exclude=.git \
                          --exclude=node_modules \
                          --exclude=.env \
                          ./ ${EC2_USER}@${EC2_HOST}:${APP_DIR}/

                        echo "===== RESTART APP ON EC2 ====="
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} << 'EOF'
                          set -e
                          export PATH=/home/unique/.nvm/versions/node/v24.12.0/bin:$PATH

                          cd /opt/chat-app

                          npm install
                          pm2 restart chat-app || pm2 start app.js --name chat-app
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
