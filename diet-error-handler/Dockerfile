FROM ruby:2.3.1

ENV PORT 3129

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

CMD bash -c "bundle exec ruby app.rb -p $PORT -o '0.0.0.0'"
