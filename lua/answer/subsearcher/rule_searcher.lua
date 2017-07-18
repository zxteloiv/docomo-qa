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

        local tpl_content = require(RULE_PATH .. tpl)
        local runner = template_container(tpl_content)
        local query_repr = query_schema.QueryRepr.new()
        local match_score = runner:run(query_repr, question, lng, lat)

        local rtn = { errno = 0, errmsg = "template processed" }
        rtn.match_score = match_score
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
        local match_score = func_exe.match(query_repr, question, lng, lat)
        local rtn = { errno = 0, errmsg = "func processed" }
        rtn.match_score = match_score
        rtn.query_repr = query_repr

        return rtn
    end
end

local function fill_poi_input_args(input_schema, input_value)
    local args = {}
    -- input type and values
    for i, schema in ipairs(input_schema) do
        local val = input_value[i]
        if schema == query_schema.POI_ATTR.NAME then
            args.name = val
        elseif schema == query_schema.POI_ATTR.COORDINATES then
            args.near_lng = val[1]
            args.near_lat = val[2]
        elseif schema == query_schema.POI_ATTR.CITY then
            args.city = val
        elseif schema == query_schema.POI_ATTR.TAG then
            args.tag = val
        elseif schema == query_schema.POI_ATTR.GENERAL then
            args.func = val
        end
    end

    return args
end

local function build_response_from_poi_result(res)
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
    return rtn
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

    local args = fill_poi_input_args(query_repr.input_schema, query_repr.input_value)

    -- downstream type
    if query_repr.downstream == query_schema.DOWNSTREAM.BAIDU_MAP then
        args.downstream = "baidu"
    elseif query_repr.downstream == query_schema.DOWNSTREAM.DOCOMO then
        args.downstream = "solr"
    else
        -- not specifying will be defaulted to baidu later in poi API
    end


    local res = ngx.location.capture('/api/geo/poi', { args = args })
    local rtn = build_response_from_poi_result(res)
    rtn.query_repr = analysis.query_repr
    rtn.match_score = analysis.match_score

    return rtn
end

-- answer a question based on its analysis result and user's location
--
--  @analysis a dict output from query analyzer
--  @lng longitude of user's current location
--  @lat latitude of user's current location
--
--  @return an answer dict
--
local function respond_complex(analysis, lng, lat)
    local query_repr = analysis.query_repr
    local input_pipe = query_repr.input_pipe

    local rtn = { errno = 0, errmsg = '', data = {} }
    local last_docs = {}
    local beam_size = 20

    ngx.log(ngx.DEBUG, "I'm starting to loop input_pipe, in respond_complex")

    for id, input in ipairs(input_pipe) do
        -- set args for this turn
        local args = fill_poi_input_args(input.schema, input.value)
        args.downstream = "solr" -- complex queries only supported on solr engine

        local current_docs = {}
        ngx.log(ngx.INFO, "\n===============\n" .. json.encode(last_docs) .. "\n============\n")
        -- args name is not specified in input_pipe and not the first one
        if (not args.name) and id > 1 then
            ngx.log(ngx.DEBUG, "I'm going to iterate over last docsets")
            for _, doc in ipairs(last_docs) do
                args.name = doc.general_val

                local res = ngx.location.capture('/api/geo/poi', {args = args})
                local res = build_response_from_poi_result(res)
                -- if any error occured, the result can be returned as errmsg
                if res.errno ~= 0 then return res end

                -- pruning to beamsize in advance 
                for id, newdoc in ipairs(res.data) do if id <= beam_size then
                    table.insert(current_docs, newdoc)
                end end
            end
            
            -- choose the top-beamsize items into last_docs
            table.sort(current_docs, function (x, y) return x.score > y.score end)
            last_docs = {}
            for id, newdoc in ipairs(current_docs) do if id <= beam_size then
                table.insert(last_docs, newdoc)
            end end

        else
            ngx.log(ngx.DEBUG, "I'm going to retrieve docset for the first time")
            local res = ngx.location.capture('/api/geo/poi', {args = args})
            local res = build_response_from_poi_result(res)
            -- if any error occured, the result can be returned as errmsg
            if res.errno ~= 0 then return res end

            -- choose the top-beamsize items into last_docs for the sorted docset
            for id, newdoc in ipairs(res.data) do if id <= beam_size then
                table.insert(current_docs, newdoc)
            end end

            last_docs = current_docs
        end
    end
    rtn.data = last_docs
    rtn.query_repr = analysis.query_repr
    rtn.match_score = analysis.match_score

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
    local query_analysis = {}
    if GET.req_type == "tpl" then
        query_analysis = match_with_template(GET.tpl, q, GET.lng, GET.lat)
    else
        query_analysis = match_with_func(GET.func, q, GET.lng, GET.lat)
    end

    -- responder
    --
    local answer = {errno = 0, errmsg = 'tpl not matched'}
    if query_analysis.match_score and query_analysis.match_score > 0 then

        if #query_analysis.query_repr.input_pipe <= 1 then
            -- query is simple
            ngx.log(ngx.DEBUG, "I'm a SIMPLE query")
            answer = respond(query_analysis, lng, lat)
        else
            -- query is complex
            ngx.log(ngx.DEBUG, "I'm a COMPLEX query")
            answer = respond_complex(query_analysis, lng, lat)
        end
    end

    -- add template info into every returned doc
    --
    local req_type = "tpl"
    if GET.req_type then req_type = GET.req_type end
    if answer.data then for i, _ in ipairs(answer.data) do
        answer.data[i][req_type] = GET[req_type]
    end end

    ngx.say(json.encode(answer))
end

main(GET)


