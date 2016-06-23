local ts = require("./lua/answer/template_schema")
local qs = require("./lua/answer/query_schema")

local conf = {

    match_type = ts.MATCH_TYPE.EXACT,

    units = {
        {
            -- first unit
            tag = ts.UNIT_TYPE.TEXT,
            content = "哪里可以"
        },

        {
            -- second unit
            tag = ts.UNIT_TYPE.TEXT,
            content = "按摩"
        },
    },

    fills = {
        ts.FILL_TAGS.LNG,
        ts.FILL_TAGS.LAT
    }
}

ngx.say("in example_template")

return conf

