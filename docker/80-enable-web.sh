#!/bin/sh

if [ -n "$RUN_WEB_SERVER" ]; then
  rm -f /etc/service/nginx/down
fi
