#!/bin/sh

if [ -n "$RUN_SPHINX" ]; then
  export RAILS_ENV=production
  (bundle exec rake ts:index && bundle exec rake ts:start) &
fi
