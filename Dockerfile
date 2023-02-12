FROM ruby:2.5
RUN apt-get update -qq
RUN gem install bundler -v 2.3.26
WORKDIR /app
COPY . /app
RUN bundle install

