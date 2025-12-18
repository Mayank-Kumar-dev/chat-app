#!/bin/bash
set -e

# Load NVM (required for Jenkins non-interactive shell)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Ensure Node 18 exists and use it
nvm install 18
nvm use 18

# Ensure PM2 is installed
command -v pm2 >/dev/null 2>&1 || npm install -g pm2

# Go to app directory
cd /opt/chat-app

# Install dependencies
npm install

# Restart or start app with PM2
pm2 restart chat-app || pm2 start app.js --name chat-app
