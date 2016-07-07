local trie_client = require("./lua/utils/tis_client")
local json = require("cjson")

local test_func = function()
    local arr = trie_client.call_tis("新中关", "poi", 1)
    assert(arr and arr.errno and arr.errmsg and arr.errno == 0 and arr.data)
    assert(arr.data[1] == 9)
end

return test_func

