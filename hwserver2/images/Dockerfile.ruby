FROM ruby:2.3

RUN mkdir /app
WORKDIR /app

VOLUME ["/app"]

ENTRYPOINT ruby entrypoint.rb > output 2>&1
