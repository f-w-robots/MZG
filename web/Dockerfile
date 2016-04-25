FROM node:4.4-slim

RUN apt-get update && apt-get install -y git && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir /app && npm install -g bower@1.7.7 ember-cli@2.3.0

WORKDIR /app

COPY package-ember-base.json /app/package.json
RUN npm install

COPY package.json bower.json /app/
RUN npm install && bower install --allow-root

ADD . /app/
