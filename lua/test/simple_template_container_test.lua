local template_container = require("./lua/answer/simple_template_container")

local str_starts_with = template_container.str_starts_with

local function str_starts_with_test()
    local from, to = str_starts_with("abc", "abc")
    assert(from == 1 and to == 3)

    from, to = str_starts_with("abc", "ab")
    assert(from == 1 and to == 2)

    from, to = str_starts_with("", "abc")
    assert(from == 0 and to == 0)

    from, to = str_starts_with("2.71828", "")
    assert(from == 0 and to == 0)

    from, to = str_starts_with(nil, "abc")
    assert(from == 0 and to == 0)

    from, to = str_starts_with("3.14159", nil)
    assert(from == 0 and to == 0)

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

    ngx.say("str_starts_with_test success (12/12)")
end

return function()
    str_starts_with_test()
end

