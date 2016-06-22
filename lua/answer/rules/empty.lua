local RULE_ = {}

local qs = require("./lua/answer/query_schema")
local ts = require("./lua/answer/template_schema")

RULE_.match = function (question, query_repr) 
    ngx.say("in empty rule")

    query_repr:set_qtype(qs.QTYPE.PIPELINE)
    query_repr:add_input(qs.POI_ATTR.NAME, "forbidden city")
    query_repr:add_input(qs.POI_ATTR.CITY, "beijing")
    return true
end

return RULE_
