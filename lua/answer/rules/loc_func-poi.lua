local ts = require("./lua/answer/template_schema")
local qs = require("./lua/answer/query_schema")

local conf = {

    match_type = ts.MATCH_TYPE.EXACT,

    units = {
        {
            -- first unit
            tag = ts.UNIT_TYPE.DICT,
            content = "location_func",
            output = qs.POI_ATTR.ADDRESS,
        },

        {
            -- second unit
            tag = ts.UNIT_TYPE.DICT,
            content = "poi",
            input = qs.POI_ATTR.NAME,
        },
    },

    fills = {
        ts.FILL_TAGS.CITY_BY_LNGLAT,
    }
}

return conf

