FROM node:4

RUN mkdir /app && npm install -g bower ember-cli

WORKDIR /app

COPY *.json /app/
RUN npm install && bower install --allow-root

ADD ./ /app
