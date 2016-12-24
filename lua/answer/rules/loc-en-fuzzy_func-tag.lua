local ts = require("./lua/answer/template_schema")
local qs = require("./lua/answer/query_schema")

local conf = {

    match_type = ts.MATCH_TYPE.FUZZY,

    units = {
        {
            -- first unit
            tag = ts.UNIT_TYPE.RE,
            content = "有哪些|is *there *any|re *there *any",
            output = qs.POI_ATTR.ADDRESS,
        },

        {
            -- second unit
            tag = ts.UNIT_TYPE.RE,
            content = ".{3,}",
            input = qs.POI_ATTR.TAG,
        },
    },

    fills = {
        ts.FILL_TAGS.CITY_BY_LNGLAT,
    },

    downstream = qs.DOWNSTREAM.DOCOMO
}

return conf

