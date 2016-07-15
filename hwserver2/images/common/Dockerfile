FROM ubuntu:16.04

RUN apt-get update && apt-get install -y nodejs npm ruby
RUN cp /usr/bin/nodejs /usr/bin/node

WORKDIR /app/system-server/

ADD ssh.js /app/system-server/

RUN npm install express pty.js socket.io

WORKDIR /app/source/
