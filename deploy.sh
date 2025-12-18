#!/bin/bash
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
nvm use 18
npm install
pm2 restart chat-app || pm2 start app.js --name chat-app
