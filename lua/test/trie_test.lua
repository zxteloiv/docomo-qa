local trie = require("./lua/utils/trie")
local json = require("cjson")

local test_func = function()

    local t = trie()
    assert(not t:get("nothing"))

    t:add("abc")
    t:add("abcd")
    t:add("水能载舟亦能覆舟")
    t:add("水能载舟亦可赛艇")

    assert(t:get("abc"))
    assert(t:get("abcd"))
    assert(t:get("水能载舟亦能覆舟"))
    assert(t:get("水能载舟亦可赛艇"))
    assert(not t:get("几百个教授一致通过"))
    assert(not t:get("水能载舟"))

    ngx.say(json.encode(t))
    ngx.say("trie_test success (7/7)")
end

return test_func
