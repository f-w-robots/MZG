FROM node:4

RUN npm install -g bower

RUN mkdir /app
WORKDIR /app

COPY package.json /app/package.json
COPY bower.json /app/bower.json
RUN npm install
RUN bower install --allow-root

ADD ./ /app
