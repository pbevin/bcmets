#!/bin/sh

if [ -n "$RUN_CRON" ]; then
  crontab -u app /bcmets/crontab
fi
