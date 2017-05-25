#!/usr/bin/env bash

# https://stackoverflow.com/questions/34962020/cron-and-crontab-files-not-executed-in-docker
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=647193
touch /etc/crontab /etc/cron.*/*

export EXTRA_OPTS='-L 15'

service cron start

exec /entrypoint.sh mysqld $@
