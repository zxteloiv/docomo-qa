local ts = require("./lua/answer/template_schema")
local qs = require("./lua/answer/query_schema")

local conf = {

    match_type = ts.MATCH_TYPE.EXACT,

    units = {
        {
            -- first unit
            tag = ts.UNIT_TYPE.DICT,
            content = "place"
        },

        {
            -- second unit
            tag = ts.UNIT_TYPE.DICT,
            content = "func"
        },
    },

    fills = {
        ts.FILL_TAGS.LNG,
        ts.FILL_TAGS.LAT
    }
}

return conf

