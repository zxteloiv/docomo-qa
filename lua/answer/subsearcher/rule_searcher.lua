-- Defines another interface to be called internally by ngc.location.capture_multi,
-- making the template matching multithreaded
--
ngx.req.read_body()
local GET = ngx.req.get_uri_args()
local json = require("rapidjson")

local query_schema = require("./lua/answer/query_schema") 
local template_container = require("./lua/answer/simple_template_container").Container
local RULE_PATH = './lua/answer/rules/'

-- Interface: try to match a question using a template
-- Parameters:
--      tpl: template file name (dirpath excluded)
--      question: question content
--      lng: longitude
--      lat: latitude
--
-- Return: a dict contains the following keys:
--      errno: error number, 0 means success, other numbers all mean error
--      errmsg: contains some description of error when errno > 0
--      matched: true if the question is matched by specific template, otherwise false
--      repr: a query representation object
--
local function match_with_template(tpl, question, lng, lat)
    if not tpl or not pcall(function() require(RULE_PATH .. tpl) end) then

        return {errno = 1, errmsg = "specified template not found", repr = nil}

    else

        local matched = false
        local tpl_content = require(RULE_PATH .. tpl)
        local runner = template_container(tpl_content)
        local query_repr = query_schema.QueryRepr.new()
        matched = runner:run(query_repr, question, lng, lat)

        local rtn = { errno = 0, errmsg = "template processed" }
        rtn.matched = matched
        rtn.query_repr = query_repr

        return rtn
    end
end

-- Interface: try to match a question using a hard-coded function
-- Parameters:
--      func: function file name (dirpath excluded)
--      question: question content
--      lng: longitude
--      lat: latitude
--
-- Return: a dict contains the following keys:
--      errno: error number, 0 means success, other numbers all mean error
--      errmsg: contains some description of error when errno > 0
--      matched: true if the question is matched by specific template, otherwise false
--      repr: a query representation object
--
local function match_with_func(func, question, lng, lat)
    if not func or not pcall(function() require(RULE_PATH .. func) end) then
        return {errno = 2, errmsg = "specified function not found", repr = nil}
    else
        local func_exe = require(RULE_PATH .. func)
        local query_repr = query_schema.QueryRepr.new()
        local matched = func_exe.match(query_repr, question, lng, lat)
        local rtn = { errno = 0, errmsg = "func processed" }
        rtn.matched = matched
        rtn.query_repr = query_repr

        return rtn
    end
end

-- answer a question based on its analysis result and user's location
--
--  @analysis a dict output from query analyzer
--  @lng longitude of user's current location
--  @lat latitude of user's current location
--
--  @return an answer dict
--
local function respond(analysis, lng, lat)
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
        elseif schema == qs.POI_ATTR.GENERAL then
            args.func = val
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

    local rtn = { errno = 0, errmsg = '', data = {} }
    rtn.data = res.data
    rtn.query_repr = analysis.query_repr
    rtn.downstream_args = args

    return rtn
end

local function main(GET)
    local rtn = {}
    if not GET.q then ngx.say(json.encode({errno=3, errmsg="no given question"})) end

    -- preprocessing
    --
    local q = ngx.re.gsub(GET.q, "([A-Za-z])[ \t]+([^A-Za-z])", '$1$2', 'ju')
    q = ngx.re.gsub(q, "([^A-Za-z])[ \t]+([A-Za-z])", '$1$2', 'ju')

    -- query analysis
    --
    if GET.req_type == "tpl" then
        rtn = match_with_template(GET.tpl, q, GET.lng, GET.lat)
    else
        rtn = match_with_func(GET.func, q, GET.lng, GET.lat)
    end

    -- responder
    --
    local answer = respond(query_analysis, lng, lat)

    ngx.say(json.encode(rtn))
end

main(GET)


