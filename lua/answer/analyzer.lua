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

    for _, rule in pairs(rules) do
        if rule.match and rule.match(question, query_repr) then
            break
        end
    end

    return {
        errno = 0,
        errmsg = '',
        query_repr = QueryRepr.new(),
        pos = {},
        parse = {},
        depparse = {},
    }
end

-- export symbols
M_.analyze = analyze

return M_


