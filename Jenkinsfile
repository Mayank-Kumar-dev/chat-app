pipeline {
    agent any

    environment {
        APP_NAME = "chat-app"
        APP_DIR  = "/opt/chat-app"

        // Node installed via NVM on EC2 (unique user)
        NODE_BIN = "/home/unique/.nvm/versions/node/v24.12.0/bin"

        // Jenkins Credentials ID (SSH Private Key)
        SSH_CRED = "aws-ec2-ssh"

        // EC2 user + IP
        EC2_HOST = "unique@3.233.131.221"
    }

    stages {

        /* =======================
           STAGE 1: CHECKOUT CODE
        ======================== */
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        /* =======================
           STAGE 2: BUILD ON JENKINS
        ======================== */
        stage('Build on Jenkins') {
            steps {
                sh '''
                    set -e

                    echo "===== NODE VERSION ====="
                    node -v
                    npm -v

                    echo "===== INSTALL DEPENDENCIES ====="
                    npm install

                    echo "===== CREATE ARTIFACT ====="
                    rm -f chat-app.tar.gz

                    tar --warning=no-file-changed \
                        -czf chat-app.tar.gz \
                        --exclude=node_modules \
                        --exclude=.git \
                        --exclude=chat-app.tar.gz \
                        .
                '''
            }
        }

        /* =======================
           STAGE 3: DEPLOY TO AWS EC2
        ======================== */
        stage('Deploy to AWS EC2') {
            steps {
                sshagent(credentials: ["${SSH_CRED}"]) {
                    sh '''
                        echo "===== COPY ARTIFACT ====="
                        scp -o StrictHostKeyChecking=no \
                            chat-app.tar.gz \
                            ${EC2_HOST}:${APP_DIR}/

                        echo "===== DEPLOY & RESTART APP ====="
                        ssh -o StrictHostKeyChecking=no ${EC2_HOST} << EOF
                            set -e

                            export PATH=${NODE_BIN}:\$PATH
                            cd ${APP_DIR}

                            echo "Extracting build..."
                            tar -xzf chat-app.tar.gz

                            echo "Restarting PM2..."
                            ${NODE_BIN}/pm2 delete ${APP_NAME} || true
                            ${NODE_BIN}/pm2 start app.js --name ${APP_NAME}

                            ${NODE_BIN}/pm2 save
                        EOF
                    '''
                }
            }
        }
    }

    /* =======================
       POST ACTIONS
    ======================== */
    post {
        success {
            echo "✅ Deployment completed successfully"
        }
        failure {
            echo "❌ Deployment failed – check logs"
        }
    }
}
