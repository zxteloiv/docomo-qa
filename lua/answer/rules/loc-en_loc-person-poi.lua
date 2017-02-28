local ts = require("./lua/answer/template_schema")
local qs = require("./lua/answer/query_schema")

local conf = {

    match_type = ts.MATCH_TYPE.FUZZY,

    units = {
        {
            -- first unit
            tag = ts.UNIT_TYPE.TEXT,
            content = "hometown",
        },

        {
            -- second unit
            tag = ts.UNIT_TYPE.RE,
            content = "director",
        },

        {
            tag = ts.UNIT_TYPE.TEXT,
            content = "of ",
        },

        {
            tag = ts.UNIT_TYPE.RE,
            content = ".*",
        },
    },

    input_pipe = {
        { schema = {qs.POI_ATTR.NAME, qs.POI_ATTR.GENERAL}, match_units = {4, 2}},
        { schema = {qs.POI_ATTR.GENERAL}, match_units = {1}},
    },

    output_pipe = {
        -- both subsequent queries require as output the tail entity w.r.t relation
        { qs.POI_ATTR.GENERAL },
        { qs.PERSON_ATTR.GENERAL }
    },

    downstream = qs.DOWNSTREAM.DOCOMO

}

return conf


