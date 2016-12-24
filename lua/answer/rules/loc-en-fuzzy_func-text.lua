local ts = require("./lua/answer/template_schema")
local qs = require("./lua/answer/query_schema")

local conf = {
    match_type = ts.MATCH_TYPE.FUZZY,

    units = {
        {
            tag = ts.UNIT_TYPE.RE,
            content = "where is|where|address|addr|地址|地点",
            output = qs.POI_ATTR.ADDRESS,
        },

        {
            tag = ts.UNIT_TYPE.RE,
            content = ".{3,}",
            input = qs.POI_ATTR.NAME, -- only supported in docomo search
        }
    },

    fills = { },

    downstream = qs.DOWNSTREAM.DOCOMO
}

return conf

