FROM ruby:2.3-alpine

RUN apk add --update \
  build-base \
  && rm -rf /var/cache/apk/*

WORKDIR /app

ADD Gemfile Gemfile.lock /app/

RUN bundle install --jobs=5

ADD . /app
