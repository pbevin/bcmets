#!/bin/sh

echo checking web server...

if [ -n $RUN_WEB_SERVER ]; then
  echo enabling it
  rm -f /etc/service/nginx/down
fi
