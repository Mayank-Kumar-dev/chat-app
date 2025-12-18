#!/bin/bash
set -ex   # 👈 show commands + fail fast

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

nvm install 18
nvm use 18

cd /opt/chat-app

echo "---- GIT STATUS ----"
git status

echo "---- GIT PULL ----"
git pull origin main

echo "---- NPM INSTALL ----"
npm install

echo "---- PM2 ----"
pm2 restart chat-app || pm2 start app.js --name chat-app
