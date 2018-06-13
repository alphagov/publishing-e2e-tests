FROM ruby:2.5.1
RUN apt-get update -qq && apt-get upgrade -y

RUN curl -sL https://deb.nodesource.com/setup_9.x | bash -
RUN apt-get install -y build-essential libpq-dev libxml2-dev libxslt1-dev \
    libfontconfig1 libfontconfig1-dev nodejs && \
  apt-get clean
RUN npm install -g phantomjs-prebuilt@2 --unsafe-perm

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME
