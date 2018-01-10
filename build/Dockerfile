FROM zxteloiv/docker-openresty-ubuntu:latest-xenial

# install deps
RUN apt update && apt install -y cmake
RUN /usr/local/openresty/luajit/bin/luarocks install split
RUN /usr/local/openresty/luajit/bin/luarocks install rapidjson

CMD ["echo Start with docker run please."]
