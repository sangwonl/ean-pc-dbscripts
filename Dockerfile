FROM mysql:5.6
MAINTAINER Sangwon Lee (gamzabaw@gmail.com)

RUN apt-get update && apt-get install -y wget unzip cron

ADD ./docker-entry.sh /
ADD ./crontab /etc/
ADD . /home/eanuser/

VOLUME /home/eanuser/eanfiles

ENTRYPOINT ["/docker-entry.sh"]