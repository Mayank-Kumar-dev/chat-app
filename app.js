const express = require('express');
const app = express();
const http = require('http');
const server = http.createServer(app);
const {Server}= require('socket.io');
const io =new Server(server)
port = 3000 ; 


app.get('/', (req, res) => {
    res.sendFile(__dirname +'/public/index.html');
  });

  io.on('connection', (socket) => {
    socket.on('chat message', (msg) => {
      console.log('message1: ' + msg);
      io.emit("message",msg)
    });
  });

server.listen(port,()=>{
    console.log(`server is running on port ${port}`);
})