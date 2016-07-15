FROM ruby:2.3

WORKDIR /app

ADD Gemfile Gemfile.lock /app/

RUN bundle install --jobs=5

ADD . /app
