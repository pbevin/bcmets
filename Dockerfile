FROM phusion/passenger-ruby23:0.9.27
RUN apt-get update -qq && apt-get install -y sphinxsearch tzdata
RUN mkdir /bcmets && chown app /bcmets
WORKDIR /bcmets

USER app
COPY Gemfile Gemfile
COPY --chown=app Gemfile.lock Gemfile.lock
RUN bundle --deployment

USER root
RUN rm -f /etc/nginx/sites-enabled/default
COPY docker/80-enable-web.sh /etc/my_init.d
COPY docker/80-enable-cron.sh /etc/my_init.d
COPY docker/crontab /bcmets/crontab
COPY docker/nginx-bcmets.conf /etc/nginx/sites-enabled/bcmets.conf
COPY docker/nginx-env.conf /etc/nginx/main.d/env.conf

COPY config.ru config.ru
COPY Rakefile Rakefile
COPY script script
COPY config config
COPY vendor/assets vendor/assets
COPY db db
COPY app app
COPY lib lib
COPY public public

COPY docker/assets-database.yml config/database.yml
RUN bundle exec rake assets:precompile RAILS_ENV=production
COPY config/database.yml config/database.yml
RUN chown -R app tmp
