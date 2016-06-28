local ts = require("./lua/answer/template_schema")
local qs = require("./lua/answer/query_schema")

local conf = {

    match_type = ts.MATCH_TYPE.EXACT,

    units = {
        {
            -- first unit
            tag = ts.UNIT_TYPE.DICT,
            content = "place",
            input = qs.POI_ATTR.NAME,
        },

        {
            -- second unit
            tag = ts.UNIT_TYPE.DICT,
            content = "func",
            output = qs.POI_ATTR.ADDRESS,
        },
    },

    fills = {
        ts.FILL_TAGS.CITY_BY_LNGLAT,
    }
}

return conf

