local ts = require("./lua/answer/template_schema")
local qs = require("./lua/answer/query_schema")

local conf = {

    match_type = ts.MATCH_TYPE.EXACT,

    units = {
        {
            -- first unit
            tag = ts.UNIT_TYPE.RE,
            content = "[^的]+",
            input = qs.POI_ATTR.NAME,
        },

        {
            tag = ts.UNIT_TYPE.RE,
            content = "的",
        },

        {
            -- functional semantic
            tag = ts.UNIT_TYPE.RE,
            content = "[^是]+",
            output = qs.POI_ATTR.GENERAL,
            input = qs.POI_ATTR.GENERAL,
        },

        {
            tag = ts.UNIT_TYPE.TEXT,
            content = "是",
        },
    },

    fills = {
        ts.FILL_TAGS.CITY_BY_LNGLAT,
    },

    downstream = qs.DOWNSTREAM.DOCOMO
}

return conf

