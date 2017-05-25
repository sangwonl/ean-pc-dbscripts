FROM mysql:5.6
MAINTAINER Sangwon Lee (gamzabaw@gmail.com)

RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

RUN apt-get update && apt-get install -y wget unzip cron rsyslog

ADD ./docker-entry.sh /
ADD ./crontab /etc/
ADD . /home/eanuser/

VOLUME /home/eanuser/eanfiles

ENTRYPOINT ["/docker-entry.sh"]