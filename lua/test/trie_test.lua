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

    local iter, b, e

    iter = t:gmatch("abcd", 1)
    b, e = iter()
    assert(b and e and b == 1 and e == 3)
    b, e = iter()
    assert(b and e and b == 1 and e == 4)
    b, e = iter()
    assert(not b and not e)

    iter = t:gmatch("ab", 1)
    b, e = iter()
    assert(not b and not e)

    iter = t:gmatch("abd")
    b, e = iter()
    assert(not b and not e)

    iter = t:gmatch("abd", 1)
    b, e = iter()
    assert(not b and not e)

    -- UTF-8 test
    iter = t:gmatch("要知道，水能载舟亦能覆舟")
    b, e = iter()
    assert(not b and not e)

    iter = t:gmatch("要知道，水能载舟亦能覆舟", 13)
    b, e = iter()
    assert(b and e)

    ngx.say("trie_test success (15/15)")
end

return test_func
