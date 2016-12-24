local ts = require("./lua/answer/template_schema")
local qs = require("./lua/answer/query_schema")

local conf = {

    match_type = ts.MATCH_TYPE.FUZZY,

    units = {
        {
            -- first unit
            tag = ts.UNIT_TYPE.DICT,
            content = "poi",
            input = qs.POI_ATTR.NAME,
        },

        {
            -- second unit
            tag = ts.UNIT_TYPE.DICT,
            content = "general_func",
            output = qs.POI_ATTR.GENERAL,
            input = qs.POI_ATTR.GENERAL,
        },
    },

    fills = {
        ts.FILL_TAGS.CITY_BY_LNGLAT,
    },

    downstream = qs.DOWNSTREAM.DOCOMO
}

return conf

