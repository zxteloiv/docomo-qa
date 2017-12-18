#!/bin/bash

ROOT=$(pwd)
NGINX_BIN=/usr/bin/openresty

mkdir -p $ROOT/logs

echo root: $ROOT
echo conf: conf/nginx.conf
$NGINX_BIN -c conf/nginx.conf -p $ROOT/ -g "daemon off;"
if [ $? -eq 0 ]; then
    echo successfully started!
fi
