local template_container = require("./lua/answer/simple_template_container")
local ts = require("./lua/answer/template_schema")
local json = require("rapidjson")

local str_starts_with = template_container.str_starts_with

local function str_starts_with_test()
    local from, to = str_starts_with("abc", "abc")
    assert(from == 1 and to == 3)

    from, to = str_starts_with("abc", "ab")
    assert(from == 1 and to == 2)

    from, to = str_starts_with("", "abc")
    assert(not from and not to)

    from, to = str_starts_with("2.71828", "")
    assert(not from and not to)

    from, to = str_starts_with(nil, "abc")
    assert(not from and not to)

    from, to = str_starts_with("3.14159", nil)
    assert(not from and not to)

    -- position test
    from, to = str_starts_with("aaaa", "a")
    assert(from == 1 and to == 1)

    from, to = str_starts_with("aaaa", "a", 1)
    assert(from == 1 and to == 1)

    from, to = str_starts_with("aaaa", "a", 2)
    assert(from == 2 and to == 2)

    from, to = str_starts_with("aaaa", "aa", 2)
    assert(from == 2 and to == 3)

    -- UTF-8 test
    from, to = str_starts_with("丧尸暴龙兽", "丧")
    assert(from == 1 and to == 3)

    from, to = str_starts_with("丧尸暴龙兽", "暴龙", 7)
    assert(from == 7 and to == 12)

    from, to = str_starts_with("附近的那个公园怎么走", "的那个", 7)
    assert(from == 7 and to == 15)

    ngx.say("str_starts_with_test success (13/13)")
end

local str_starts_with_re = template_container.str_starts_with_re

local function str_starts_with_re_test()
    local from, to = str_starts_with_re("abc", "abc")
    assert(from == 1 and to == 3)

    from, to = str_starts_with_re(nil, "abc")
    assert(not from and not to)

    from, to = str_starts_with_re("abc", nil)
    assert(not from and not to)

    from, to = str_starts_with_re("", "")
    assert(not from and not to)

    from, to = str_starts_with_re("abc", "bc", 1)
    assert(not from and not to)

    from, to = str_starts_with_re("abc", "bc", 2)
    assert(from == 2 and to == 3)

    -- UTF-8 test
    from, to = str_starts_with_re("你为什么这么熟练啊", "为什么", 4)
    assert(from == 4 and to == 12)

    from, to = str_starts_with_re("你为什么这么熟练啊", "为什么", 1)
    assert(not from and not to)

    ngx.say("str_starts_with_re_test success (8/8)")
end

local Container = template_container.Container
local function container_gmatch_test()
    local extract = function (q, span) return string.sub(q, span[1], span[2]) end
    local tpl = {
        match_type = ts.MATCH_TYPE.EXACT,
        units = {
            { tag = ts.UNIT_TYPE.TEXT, content = "abc"},
            { tag = ts.UNIT_TYPE.RE, content = "d+"},
            { tag = ts.UNIT_TYPE.RE, content = "美食"}
        }
    }
    local c = Container(tpl)
    local question = "abcdddd美食"
    local iter = c:gmatch(question, 1)
    local match = iter()
    assert(match and #match == 3)
    assert(extract(question, match[1]) == "abc")
    assert(extract(question, match[2]) == "dddd")
    assert(extract(question, match[3]) == "美食")

    local iter = c:gmatch("abc", 1)
    local match = iter()
    assert(not match)

    local iter = c:gmatch("abc美食", 1)
    local match = iter()
    assert(not match)

    tpl.match_type = ts.MATCH_TYPE.FUZZY
    local c = Container(tpl)
    local question = "  abc   ddd    美食   "
    local iter = c:gmatch(question, 1)
    local match = iter()
    assert(match and #match == 3)
    assert(extract(question, match[1]) == "abc")
    assert(extract(question, match[2]) == "ddd")
    assert(extract(question, match[3]) == "美食")

    local iter = c:gmatch("  abc   美食 ddd   ")
    local match = iter()
    assert(not match)

    ngx.say("container_gmatch_test success (5/5)")
end

local test_func = function()
    str_starts_with_test()
    str_starts_with_re_test()
    container_gmatch_test()
end

return test_func


