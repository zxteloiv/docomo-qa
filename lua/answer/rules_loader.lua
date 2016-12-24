local M_ = {}

local empty_runner = require("./lua/answer/rules/empty")
local template_container = require("./lua/answer/simple_template_container").Container

local rule_list_debug = {
    -- test
    {template_container, require("./lua/answer/rules/en_poi-predicate")},
}

local rule_list = {
    -- exact search on solr
    -- 国家图书馆 的 创建时间 是
    {template_container, require("./lua/answer/rules/poi-generalFunc")},
    -- what is the creating time of sth.
    {template_container, require("./lua/answer/rules/en_poi-predicate")},

    -- search on baidumap
    -- 酒店 怎么走
    {template_container, require("./lua/answer/rules/loc_category-func")},
    -- 公园
    {template_container, require("./lua/answer/rules/loc_category")},
    -- 哪里有 酒店
    {template_container, require("./lua/answer/rules/loc_func-category")},
    -- 附近 哪里有 公园
    {template_container, require("./lua/answer/rules/loc_near-func-category")},
    -- 附近 的 公园 怎么走
    {template_container, require("./lua/answer/rules/loc_near-category-func")},
    -- 附近 哪里有 兰州拉面
    {template_container, require("./lua/answer/rules/loc_near-func-poi")},
    -- 景山公园 在哪里
    {template_container, require("./lua/answer/rules/loc_poi-func")},
    -- 怎么去 景山公园
    {template_container, require("./lua/answer/rules/loc_func-poi")},
    -- ... 怎么去 ... 国家博物馆 ...
    {template_container, require("./lua/answer/rules/loc-en-fuzzy_func-poi")},
    -- 回龙观
    {template_container, require("./lua/answer/rules/loc_poi")},

    -- general search on solr
    -- where is 紫禁城 .{3,}
    {template_container, require("./lua/answer/rules/loc-en-fuzzy_func-text")},
    -- ... 有哪些 ... 5A级景区 ...
    {template_container, require("./lua/answer/rules/loc-en-fuzzy_func-tag")},
    -- ... 国家图书馆 ... 创建时间 ...
    {template_container, require("./lua/answer/rules/loc-fuzzy_poi-func")},

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

