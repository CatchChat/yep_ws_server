FROM ruby:2.3.1

ENV WORKDIR /var/www
WORKDIR $WORKDIR
ADD . $WORKDIR
RUN bundle install --without development test --deployment
RUN mkdir -p tmp/pids
EXPOSE $PORT
CMD bundle exec ruby yep_ws_server.rb -l log/$GOLIATH_ENV.log -e $GOLIATH_ENV -p $PORT -v
