FROM zxteloiv/docker-openresty-ubuntu:1.11.2.1-xenial-20161010

# install prerequisites
#
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y cmake

# QA dependencies luarocks and QA sources
#
RUN /usr/local/openresty/luajit/bin/luarocks install rapidjson
RUN /usr/local/openresty/luajit/bin/luarocks install split

ARG BAIDU_AK="yourAPIKey"

RUN mkdir -p /opt/docomo-qa
COPY . /opt/docomo-qa
WORKDIR /opt/docomo-qa
RUN cp conf/service.conf.in conf/service.conf
RUN sed -i "s/^baidu_ak.*/baidu_ak ${BAIDU_AK}/" conf/service.conf

RUN ln -sf /dev/stdout /opt/docomo-qa/logs/access.log \
    && ln -sf /dev/stderr /opt/docomo-qa/logs/error.log

RUN ln -s /usr/local/openresty/nginx/sbin/nginx nginx

EXPOSE 9527

ENTRYPOINT ["./switch.sh", "docker"]
