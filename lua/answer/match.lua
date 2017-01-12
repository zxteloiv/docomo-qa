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
        rtn.repr = query_repr

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
        return {errno = 2, errmsg = "specified template not found", repr = nil}
    else
        local func_exe = require(RULE_PATH .. func)
        local query_repr = query_schema.QueryRepr.new()
        local matched = func_exe.match(query_repr, question, lng, lat)
        local rtn = { errno = 0, errmsg = "func processed" }
        rtn.matched = matched
        rtn.repr = query_repr

        return rtn
    end
end

local function main(GET)
    local rtn = {}
    if GET.req_type == "tpl" then
        rtn = match_with_template(GET.tpl, GET.q, GET.lng, GET.lat)
    else
        rtn = match_with_func(GET.func, GET.q, GET.lng, GET.lat)
    end

    ngx.say(json.encode(rtn))
end

main(GET)


