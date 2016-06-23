local M_ = {}

local rule_list = {
    {require("./lua/answer/rules/empty"), nil},
}

-- function match
-- set the correct query representation struct by matching the question to rules
--
--  @query_repr the representation table to be modified
--  @question the string of user inputs
--  @lng the longitude of user position, nil if the data is missing
--  @lat the latitude of user position, nil if the data is missing
--  
--  @return boolean value, true if no error occured
--
function match(query_repr, question, lng, lat)
    for _, rule in pairs(rule_list) do
        if rule[2] then
            runner = rule[1](rule[2])
            runner.match(query_repr, question, lng, lat)
        else
            rule[1].match(query_repr, question, lng, lat)
        end
    end
end

-- export symbols
M_.match = match

return M_

