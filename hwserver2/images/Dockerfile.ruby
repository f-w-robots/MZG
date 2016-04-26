FROM ruby:2.3

RUN mkdir /app
WORKDIR /app

VOLUME ["/app"]

CMD ruby entrypoint.rb
