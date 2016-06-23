local M_ = {}

local rules = require("./lua/answer/rules/loader")
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

    -- match and modify the query representation for specific rules
    rules.match(query_repr, question, lng, lat)

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


