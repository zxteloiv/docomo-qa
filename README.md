# docomo-qa
An online question answering system in cooperation with docomo, implemented in OpenResty.

## **disclaimer**

This is a deprecated system. Please consider not using it.
The key value of this repo, at this time, is only two-fold.
- It's a demonstration of Lua and Openresty (though early versions), and thus simple and easy to follow.
- It had implemented a template engine that can parse user questions and call downstreams (subsearchers).

## install lua dependencies

using luarocks to install:

``` bash
luarocks install rapidjson
luarocks install split
```

## execution

``` bash
./switch.sh start   # to start the QA service
./switch.sh reload  # reload the config and lua scripts if you've changed anything
./switch.sh stop    # stop the service started before
```
