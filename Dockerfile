FROM ruby:2.3.1

ENV WORKDIR /var/www
WORKDIR $WORKDIR
ADD . $WORKDIR
RUN bundle install --without development test --deployment
RUN mkdir -p tmp/pids
EXPOSE 9000
CMD bundle exec ruby yep_ws_server.rb -l log/$RACK_ENV.log -e $RACK_ENV -p 9000 -v
