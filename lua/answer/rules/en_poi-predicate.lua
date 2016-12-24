local ts = require("./lua/answer/template_schema")
local qs = require("./lua/answer/query_schema")

local conf = {

    match_type = ts.MATCH_TYPE.FUZZY,

    units = {
        {
            -- first unit
            tag = ts.UNIT_TYPE.RE,
            content = "(who|when|what) *(is|are)",
            input = qs.POI_ATTR.NAME,
        },

        {
            -- functional semantic
            tag = ts.UNIT_TYPE.RE,
            content = "the(.+) of ",
            output = qs.POI_ATTR.GENERAL,
            input = qs.POI_ATTR.GENERAL,
        },

        {
            tag = ts.UNIT_TYPE.RE,
            content = ".{3,}",
            input = qs.POI_ATTR.NAME,
        },
    },

    fills = {
        ts.FILL_TAGS.CITY_BY_LNGLAT,
    },

    downstream = qs.DOWNSTREAM.DOCOMO
}

return conf

