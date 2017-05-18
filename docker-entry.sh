#!/usr/bin/env bash

service cron start
exec /entrypoint.sh mysqld $@
