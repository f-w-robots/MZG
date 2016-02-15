FROM node:4

RUN mkdir /app && npm install -g bower ember-cli@2.3.0-beta.1

WORKDIR /app

COPY package.json /app/
RUN npm install

COPY bower.json /app/
RUN bower install --allow-root

ADD . /app/
