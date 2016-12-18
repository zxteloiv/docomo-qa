local M_ = {}
local qs = require("./lua/answer/query_schema")
local json = require("rapidjson")

-- answer a question based on its analysis result and user's location
--
--  @analysis a dict output from query analyzer
--  @lng longitude of user's current location
--  @lat latitude of user's current location
--
--  @return an answer dict
--
local function answer(analysis, lng, lat)
    local query_repr = analysis.query_repr

    local args = {}
    -- input type and values
    for i, schema in ipairs(query_repr.input_schema) do
        local val = query_repr.input_value[i]
        if schema == qs.POI_ATTR.NAME then
            args.name = val
        elseif schema == qs.POI_ATTR.COORDINATES then
            args.near_lng = val[1]
            args.near_lat = val[2]
        elseif schema == qs.POI_ATTR.CITY then
            args.city = val
        elseif schema == qs.POI_ATTR.TAG then
            args.tag = val
        end
    end

    -- downstream type
    if query_repr.downstream == qs.DOWNSTREAM.BAIDU_MAP then
        args.downstream = "baidu"
    elseif query_repr.downstream == qs.DOWNSTREAM.DOCOMO then
        args.downstream = "solr"
    else
        -- not specifying will be defaulted to baidu later in poi API
    end


    local res = ngx.location.capture('/api/geo/poi', { args = args })

    -- check the returned value
    if not res or res.status ~= 200 then
        return {errno = 1, errmsg = "poi srv failed"}
    end
    local res = json.decode(res.body)
    if not res then
        return {errno = 2, errmsg = "returned poi data corrupted"}
    end
    if not res.data then
        return {errno = 3, errmsg = "nil data returned"}
    end

    local rtn = { errno = 0, errmsg = '', data = {}, reprtype = {} }
    rtn.data = res.data

    return rtn
end

-- export symbols
M_.answer = answer
return M_
