local trie_client = require("./lua/utils/tis_client")
local json = require("cjson")

local call_tis_test = function()
    local arr = trie_client.call_tis("新中关", "poi", 1)
    assert(arr and arr[1] == 9)
end

local test_func = function () 
    call_tis_test()
end

return test_func

