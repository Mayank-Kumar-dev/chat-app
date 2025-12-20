pipeline {
    agent any

    environment {
        EC2_USER = "unique"
        EC2_HOST = "3.233.131.221"
        APP_DIR  = "/opt/chat-app"
        SSH_CRED = "aws-ec2-ssh"
        APP_NAME = "chat-app"
    }

    stages {

        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Build on Jenkins') {
            steps {
                sh '''
                  echo "===== NODE & NPM VERSION ====="
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
                        cd /opt/chat-app

                        npm install --production

                        pm2 delete chat-app || true
                        pm2 start app.js --name chat-app
                        pm2 save
                        pm2 status
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
