local M_ = {}

local empty_runner = require("./lua/answer/rules/empty")
local template_container = require("./lua/answer/simple_template_container").Container

local rule_list = {
    {template_container, require("./lua/answer/rules/loc-en-fuzzy_func-text")},
    {template_container, require("./lua/answer/rules/loc_poi-func-2")},
    {template_container, require("./lua/answer/rules/loc-fuzzy_poi-func")},
    {template_container, require("./lua/answer/rules/loc_category-func")},
    {template_container, require("./lua/answer/rules/loc_category")},
    {template_container, require("./lua/answer/rules/loc_func-category")},
    {template_container, require("./lua/answer/rules/loc_near-func-category")},
    {template_container, require("./lua/answer/rules/loc_near-category-func")},
    {template_container, require("./lua/answer/rules/loc_near-func-poi")},
    {template_container, require("./lua/answer/rules/loc_poi-func")},
    {template_container, require("./lua/answer/rules/loc_func-poi")},
    {template_container, require("./lua/answer/rules/loc_poi")},
    {empty_runner, nil},
}

local function is_container(rule) return (rule[2] ~= nil) end

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
        local matched = false
        if is_container(rule) then
            local runner = rule[1](rule[2])
            matched = runner:run(query_repr, question, lng, lat)
        else
            matched = rule[1].match(query_repr, question, lng, lat)
        end

        if matched then break end
    end
end

-- export symbols
M_.match = match

return M_

