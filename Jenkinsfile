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
                    echo "===== NODE ====="
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
                        echo "===== SYNC CODE TO EC2 ====="
                        rsync -avz \
                          --exclude=.git \
                          --exclude=node_modules \
                          --exclude=.env \
                          ./ ${EC2_USER}@${EC2_HOST}:${APP_DIR}/

                        echo "===== RESTART APP ====="
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} << EOF
                          set -e
                          export PATH=${NODE_BIN}:\$PATH
                          cd ${APP_DIR}

                          npm install
                          pm2 restart ${APP_NAME} || pm2 start app.js --name ${APP_NAME}
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
