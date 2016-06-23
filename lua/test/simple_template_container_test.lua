local template_container = require("./lua/answer/simple_template_container")

local str_starts_with = template_container.str_starts_with

local function str_starts_with_test()
    local w, pos = str_starts_with("abc", "abc")
    assert(w == "abc" and pos == 4)

    w, pos = str_starts_with("abc", "ab")
    assert(w == "ab" and pos == 3)

    w, pos = str_starts_with("", "abc")
    assert(w == nil and pos == 0)

    w, pos = str_starts_with("2.71828", "")
    assert(w == nil and pos == 0)

    w, pos = str_starts_with(nil, "abc")
    assert(w == nil and pos == 0)

    w, pos = str_starts_with("3.14159", nil)
    assert(w == nil and pos == 0)

    -- position test
    w, pos = str_starts_with("aaaa", "a")
    assert(w == "a" and pos == 2)

    w, pos = str_starts_with("aaaa", "a", 1)
    assert(w == "a" and pos == 2)

    w, pos = str_starts_with("aaaa", "a", 2)
    assert(w == "a" and pos == 3)

    w, pos = str_starts_with("aaaa", "aa", 2)
    assert(w == "aa" and pos == 4)

    -- UTF-8 test
    w, pos = str_starts_with("丧尸暴龙兽", "丧")
    assert(w == "丧" and pos == 4, "UTF-8 test single character") 

    w, pos = str_starts_with("丧尸暴龙兽", "暴龙", 7)
    assert(w == "暴龙" and pos == 13, "UTF-8 test two characters") 

    ngx.say("str_starts_with_test success (12/12)")
end

return function()
    str_starts_with_test()
end

