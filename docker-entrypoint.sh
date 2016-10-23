#!/usr/bin/env bash



# 修改对外服务的端口
export HTTP_PORT=${HTTP_PORT:-5000}
sed -i \
    -e "s|{HTTP_PORT}|${HTTP_PORT}|" \
    /usr/local/nginx/conf/nginx.conf

export SQLITE_DB=/data/ppmessage.db
export IDENTICON_STORE=/data/ppmessage/identicon
export GENERIC_STORE=/data/ppmessage/generic

export SITE_URL=${SITE_URL:-'http://127.0.0.1:5000'}
export TRUSTED_DOMAIN=$(echo ${SITE_URL} | awk -F '[\:]' '{ print $2; }')
export TRUSTED_DOMAIN=$(echo ${TRUSTED_DOMAIN} | sed 's/\/\///g')
export MONITOR_PORT=$(echo ${SITE_URL} | awk -F '[\:]' '{ print $3; }')
echo "SITE_URL is: ${SITE_URL}"
echo "MONITOR_PORT is: ${MONITOR_PORT}"
echo "TRUSTED_DOMAIN is: ${TRUSTED_DOMAIN}"

sed -i \
    -e "s|{SQLITE_DB}|${SQLITE_DB}|" \
    -e "s|{IDENTICON_STORE}|${IDENTICON_STORE}|" \
    -e "s|{GENERIC_STORE}|${GENERIC_STORE}|" \
    -e "s|{HTTP_PORT}|${MONITOR_PORT}|" \
    -e "s|{SITE_URL}|${SITE_URL}|" \
    -e "s|{TRUSTED_DOMAIN}|${TRUSTED_DOMAIN}|" \
    /app/ppmessage/ppmessage/bootstrap/config.json


# 启动redis
service redis-server restart


# 检查是否有reset
export RESET=${RESET:-0}
if [[ ${RESET} -ne 0 ]]; then
    echo "now clear application data.."
    rm -rf /data/*
fi


if [[ -f /data/config.json ]]; then
    cp /data/config.json /app/ppmessage/ppmessage/bootstrap/config.json
fi
if [[ -f /data/pp-library.min.js ]]; then
    cp /data/pp-library.min.js /app/ppmessage/ppmessage/resource/assets/ppcom/assets/pp-library.min.js
fi
if [[ -f /data/ppkefu.min.js ]]; then
    cp /data/ppkefu.min.js /app/ppmessage/ppmessage/resource/assets/ppkefu/assets/js/ppkefu.min.js
fi
if [[ -f /data/ppconsole.min.js ]]; then
    cp /data/ppconsole.min.js /app/ppmessage/ppmessage/resource/assets/ppconsole/static/dist/ppconsole.min.js
fi

if [[ ! -f /data/ppmessage.db ]]; then
    cd /app/ppmessage
    python init.py
fi
if [[ ! -d /data/ppmessage/identicon ]]; then
    mkdir -p /data/ppmessage/identicon
fi
if [[ ! -d /data/ppmessage/generic ]]; then
    mkdir -p /data/ppmessage/generic
fi


if [[ $1 == "bash" ]]; then
    /bin/bash
else
    cd /app/ppmessage
    cron
    nginx -t
    nginx
    python ppmessage.py
fi

