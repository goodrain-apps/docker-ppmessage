FROM debian:jessie
MAINTAINER lucienchu<lucienchu@hotmail.com>

#httpredir.debian.org
#mirrors.163.com
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak \
    && echo "deb http://httpredir.debian.org/debian/ jessie main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb http://httpredir.debian.org/debian/ jessie-updates main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb http://httpredir.debian.org/debian/ jessie-backports main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb http://httpredir.debian.org/debian-security/ jessie/updates main non-free contrib" >> /etc/apt/sources.list \
    && apt-get update -q \
    && apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y git-core cron

VOLUME /data
WORKDIR /app

RUN git clone https://github.com/PPMESSAGE/ppmessage.git \
    && cd /app/ppmessage/ppmessage/scripts/ \
    && bash set-up-ppmessage-on-debian-or-ubuntu.sh

COPY config.json /app/ppmessage/ppmessage/bootstrap/
COPY docker-entrypoint.sh /usr/local/bin/
COPY crontab /etc/cron.d/
COPY init.py /app/ppmessage/

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["docker-entrypoint.sh"]
#ENTRYPOINT ["/bin/bash"]