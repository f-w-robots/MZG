FROM node:4.4.7

RUN mkdir /app && npm install -g bower@1.7.9 ember-cli@2.6.2

WORKDIR /app

COPY package.json /app/
RUN npm install

COPY bower.json /app/
RUN bower install --allow-root

ADD . /app/
