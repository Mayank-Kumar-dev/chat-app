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
                    echo "=== NODE ==="
                    node -v
                    npm -v

                    echo "=== INSTALL DEPENDENCIES ==="
                    npm install

                    echo "=== CREATE ARTIFACT ==="
                    rm -f chat-app.tar.gz

                    tar -czf chat-app.tar.gz \
                      --exclude=node_modules \
                      --exclude=.git \
                      --exclude=chat-app.tar.gz \
                      .
                '''
            }
        }

        stage('Deploy to AWS EC2') {
            steps {
                sshagent(credentials: ["${SSH_CRED}"]) {
                    sh '''
                        echo "=== COPY FILES ==="
                        scp -o StrictHostKeyChecking=no chat-app.tar.gz ${EC2_HOST}:/tmp/chat-app.tar.gz

                        echo "=== DEPLOY ON EC2 ==="
                        ssh -o StrictHostKeyChecking=no ${EC2_HOST} << EOF
                          set -e
                          export PATH=${NODE_BIN}:\$PATH

                          mkdir -p ${APP_DIR}
                          cd ${APP_DIR}

                          rm -rf *
                          tar -xzf /tmp/chat-app.tar.gz

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
            echo "✅ Deployment successful"
        }
        failure {
            echo "❌ Deployment failed"
        }
    }
}
