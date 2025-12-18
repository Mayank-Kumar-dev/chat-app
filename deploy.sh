#!/bin/bash
set -e

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

nvm install 18
nvm use 18

cd /opt/chat-app

git pull origin main   # ⭐ THIS IS THE KEY FIX

npm install
pm2 restart chat-app || pm2 start app.js --name chat-app
