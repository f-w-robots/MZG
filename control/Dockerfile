FROM ruby:2.3-alpine

RUN apk add --update \
  build-base \
  && rm -rf /var/cache/apk/*

RUN mkdir /app
WORKDIR /app

ADD Gemfile /app
ADD Gemfile.lock /app

RUN bundle install --jobs=5
