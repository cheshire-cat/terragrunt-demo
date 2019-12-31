FROM ruby:2.5.3
RUN apt-get update -qq && apt-get install -y vim build-essential libpq-dev

# fix nodejs doesn't install
# https://github.com/docker-library/ruby/issues/226
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get install -y nodejs

RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp

# fix rails not deleting pid file
# https://github.com/docker/compose/issues/1393
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]


