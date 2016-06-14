# docomo-qa
An online question answering system in cooperation with docomo, implemented in OpenResty.

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
