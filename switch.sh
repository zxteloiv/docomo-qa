#!/bin/bash

ROOT=$(pwd)
NGINX_BIN=$ROOT/nginx

if [ "$1" == "start" ]; then
    echo root: $ROOT
    echo conf: conf/nginx.conf
    $NGINX_BIN -c conf/nginx.conf -p $ROOT/
    if [ $? -eq 0 ]; then
        echo successfully started!
    fi
elif [ "$1" == "stop" -o "$1" == "reload" ]; then
    echo root: $ROOT
    echo conf: conf/nginx.conf
    $NGINX_BIN -c conf/nginx.conf -p $ROOT/ -s $1
    if [ $? -eq 0 ]; then
        echo successful $1!
    fi
else
    echo "Usage: $0 start|stop|reload"
fi

