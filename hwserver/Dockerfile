FROM ruby:2.3

RUN mkdir /app
WORKDIR /app

ADD Gemfile /app
ADD Gemfile.lock /app

RUN bundle install --jobs=5

VOLUME ["/app/log"]
