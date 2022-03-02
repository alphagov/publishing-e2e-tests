FROM ruby:2.7.5

RUN apt-get update -qq && \
    apt-get upgrade -y && \
    apt-get install -y chromium chromium-driver && \
    apt-get clean

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME
