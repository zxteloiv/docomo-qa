local M_ = {}

local rules = require("./lua/answer/rules_loader")
local query_schema = require("./lua/answer/query_schema") 

-- analyze a question, input the question string, and longitude and latitude in float numbers
--  @question a string of question
--  @lng longitude of the user's location when sending the query
--  @lat latitude of the user's location when sending the query
--
--  @return a question analysis report
--
local function analyze(question, lng, lat)
    local QueryRepr = query_schema.QueryRepr
    query_repr = QueryRepr.new()

    -- preprocessing
    question = ngx.re.gsub(question, "([A-Za-z])[ \t]+([^A-Za-z])", '$1$2', 'ju')
    question = ngx.re.gsub(question, "([^A-Za-z])[ \t]+([A-Za-z])", '$1$2', 'ju')
    if question then
        -- match and modify the query representation for specific rules
        rules.match(query_repr, question, lng, lat)
    end

    return {
        errno = 0,
        errmsg = '',
        query_repr = query_repr,
        pos = {},
        parse = {},
        depparse = {},
    }
end

-- export symbols
M_.analyze = analyze

return M_


