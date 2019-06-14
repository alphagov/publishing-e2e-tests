FROM cbaines/ruby-with-guix:2.6.3

RUN guix-daemon --disable-chroot --build-users-group=guixbuilder & \
  guix install ungoogled-chromium fontconfig font-dejavu

RUN apt-get update -qq && apt-get upgrade -y

RUN curl -sL https://deb.nodesource.com/setup_9.x | bash -
RUN apt-get install -y build-essential libpq-dev libxml2-dev libxslt1-dev \
    libfontconfig1 libfontconfig1-dev nodejs unzip xvfb && \
  apt-get clean

ENV APP_HOME /app
RUN mkdir $APP_HOME

RUN echo "source /root/.guix-profile/etc/profile" > /etc/profile.d/guix.sh
RUN chmod a+x /etc/profile.d/guix.sh

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME
