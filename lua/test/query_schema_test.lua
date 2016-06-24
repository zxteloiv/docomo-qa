local qs = require("./lua/answer/query_schema")

local test_func = function ()
    obj = qs.QueryRepr()

    obj:set_qtype(qs.QTYPE.PIPELINE)
    obj:add_input(qs.POI_ATTR.NAME, "forbidden city")
    obj:add_input(qs.POI_ATTR.CITY, "beijing")
    obj:add_output_pipe({qs.POI_ATTR.OPEN_TIME})
    obj:add_output_pipe({})
    obj:add_output_at_pos(qs.POI_ATTR.COORDINATES, 2)

    assert(obj.qtype == qs.QTYPE.PIPELINE)
    assert(type(obj.input_schema) == "table")
    assert(obj.input_schema[1] == qs.POI_ATTR.NAME)
    assert(obj.input_value[1] == "forbidden city")
    assert(obj.input_schema[2] == qs.POI_ATTR.CITY)
    assert(obj.input_value[2] == "beijing")
    assert(type(obj.output) == "table")
    assert(type(obj.output[1]) == "table")
    assert(type(obj.output[2]) == "table")
    assert(obj.output[1][1] == qs.POI_ATTR.OPEN_TIME)
    assert(obj.output[2][1] == qs.POI_ATTR.COORDINATES)

    ngx.say("query_schema_test all successful (11/11)")
end

return test_func
