local trie_client = require("./lua/utils/tis_client")
local json = require("cjson")

local call_tis_test = function()
    local arr = trie_client.call_tis("新中关", "poi", 1)
    assert(arr and arr[1] == 9)

    local arr = trie_client.call_tis("我在新中关", "poi", 7)
    assert(arr and arr[1] == 15)

    local arr = trie_client.call_tis("我在新中关", "location_func", 1)
    assert(not arr)

    ngx.say("call_tis test success (3/3)")
end

local make_tis_iter_test = function()
    local iter = trie_client.make_tis_iter("天坛公园", "poi", 1)
    local b, e = iter()
    assert(b == 1 and e == 6)
    b, e = iter()
    assert(b == 1 and e == 12)

    ngx.say("make_tis_iter test success (2/2)")
end

local test_func = function () 
    call_tis_test()
    make_tis_iter_test()
end

return test_func

