local template_container = require("./lua/answer/token_template_container")
local ts = require("./lua/answer/template_schema")
local json = require("rapidjson")

local compare_unit_and_term = template_container.compare_unit_and_term
local function compare_unit_and_term_test()
    local unit, term = {}, {}

    unit = {tag = ts.UNIT_TYPE.TEXT, content="春天"}
    term = {token = "春天", pos = "n"}
    assert(compare_unit_and_term(unit, term))
    term = {token = "夏天", pos = "n"}
    assert(not compare_unit_and_term(unit, term))
    term = {token = "春天", pos = "v"}
    assert(compare_unit_and_term(unit, term))
    term = {token = "夏天", pos = "v"}
    assert(not compare_unit_and_term(unit, term))

    unit = {tag = ts.UNIT_TYPE.RE, content=".*ed"}
    term = {token = "excited", pos = "a"}
    assert(compare_unit_and_term(unit, term))
    term = {token = "exciting", pos = "a"}
    assert(not compare_unit_and_term(unit, term))
    term = {token = "excited", pos = "x"}
    assert(compare_unit_and_term(unit, term))
    term = {token = "exciting", pos = "x"}
    assert(not compare_unit_and_term(unit, term))

    unit = {tag = ts.UNIT_TYPE.POS, content="n"}
    term = {token = "苹果", pos = "n"}
    assert(compare_unit_and_term(unit, term))
    term = {token = "苹果", pos = "v"}
    assert(not compare_unit_and_term(unit, term))
    term = {token = "水蜜桃", pos = "n"}
    assert(compare_unit_and_term(unit, term))
    
    unit = {tag = ts.UNIT_TYPE.DICT, content="poi"}
    term = {token = "海淀黄庄", pos = "n"}
    assert(compare_unit_and_term(unit, term))
    term = {token = "海淀黄庄", pos = "v"}
    assert(compare_unit_and_term(unit, term))
    term = {token = "火星", pos = "n"}
    assert(not compare_unit_and_term(unit, term))
    term = {token = "火星", pos = "v"}
    assert(not compare_unit_and_term(unit, term))

    ngx.say('compare_unit_and_term_test success (15/15)')
end

local function container_find_match_test()
    local Container = template_container.Container
    local template = { units = {
        { tag = ts.UNIT_TYPE.DICT, content = "nearby" },
        { tag = ts.UNIT_TYPE.TEXT, content = "哪里" },
        { tag = ts.UNIT_TYPE.RE, content = "有|能" },
        { tag = ts.UNIT_TYPE.POS, content = "n" },
    }}

    local runner = Container(template)
    local matches = runner:find_match("附近哪里有拉面")
    assert(matches)

    -- '按摩' has POS "v", thus should not be matched
    local matches = runner:find_match("附近哪里有按摩")
    assert(not matches)

    template.units[4] = { tag = ts.UNIT_TYPE.POS_RE, content = "n.*|v.*" }
    local matches = runner:find_match("附近哪里有按摩")
    assert(matches)

    ngx.say('container_gmatch_test success (3/3)')

end

local test_func = function()
    compare_unit_and_term_test()
    container_find_match_test()
end

return test_func
