local M_ = {}

local ts = require("./lua/answer/template_schema")
local qs = require("./lua/answer/query_schema")

local g_shared_ro = require("./lua/init")

-- match type text
-- Check if the string matches the text pattern, for the best performance
--
--  @str the input string
--  @pattern the pattern to compare with
--  @from the position index to start to compare, default to 1 if not given
--
--  @return a pair of start and ending position of the matched part.
--     If the pattern is not matched, two nil-s will be returned.
--
local str_starts_with = function (str, pattern, from)
    if not from then from = 1 end -- if from is missing, start from the beginning
    if not str or not pattern then return nil, nil end
    local len = #pattern
    if len == 0 then return nil, nil end

    for i = from, len do
        if not str:byte(i) or str:byte(i) ~= pattern:byte(i) then
            return nil, nil
        end
    end

    return from, from + len - 1
end

-- match type re
-- Check if the string matches the given regular expression, starting from the given place
--
--  @str the input string
--  @pattern the RE pattern
--  @from the starting position index
--
--  @return a pair of start and ending position of the matched part.
--     If the pattern is not matched, two nil-s will be returned.
--
local str_starts_with_re = function (str, pattern, from)
    if not str or not pattern then return nil, nil end
    if #str == 0 or #pattern == 0 then return nil, nil end

    local ctx = {pos = from}
    local from, to, err = ngx.re.find(str, pattern, "ajou", ctx)

    if from then
        return from, to
    else
        return nil, nil
    end

end

local make_iterator = function (func, ...)
    local executed = false
    return function (...)
        if not executed then return func(...) end
        return nil, nil
    end
end

-- the main container class
-- The class will take a template and then execute as the template is configured.
--
local Container = setmetatable({}, {
    __call = function (cls, template)
        return cls.new(template)
    end,
})

Container.match = function()
    assert(false, "container should not run directly")
end

Container.__index = Container
Container.new = function(template)
    local self = { rule = template }
    setmetatable(self, Container)
    return self
end

Container.make_universal_iter = function(self, question, unit, pos)
    local iter
    if unit.tag == ts.UNIT_TYPE.TEXT then
        iter = make_iterator(str_starts_with, question, unit.content, pos)
    elseif unit.tag == ts.UNIT_TYPE.RE then
        iter = make_iterator(str_starts_with_re, question, unit.content, pos)
    elseif unit.tag == ts.UNIT_TYPE.DICT then
        trie_index = g_shared_ro[unit.content]
        assert(trie_index, "the specified trie index doesn't exist")
        iter = trie_index:gmatch(question, pos)
    end

    return iter
end

Container.gmatch = function (self, question, pos)
    local rule = self.rule
    local matches = {}
    local iter_stack = {}
    local iter = self:make_universal_iter(question, rule.units[1], pos)
    table.insert(iter_stack, iter)

    return function () 
        while #iter_stack > 0 do
            local iter = iter_stack[#iter_stack]
            local from, to = iter()

            if not from or not to then
                table.remove(iter_stack, #iter_stack)
            else
                matches[#iter_stack] = {from, to}

                if #iter_stack < #(rule.units) then
                    iter = self:make_universal_iter(question,
                        rule.units[#iter_stack + 1], to + 1)
                    table.insert(iter_stack, iter)
                else
                    return matches
                end
            end
        end

        return nil
    end
end

function Container:run (query_repr, question, lng, lat)
    local iter = self:gmatch(question, 1)

    local matches = iter()

    if not matches then
        return false
    end

    -- by default, assume the pipeline has only 1 element
    if not query_repr.output[1] then
        query_repr.output[1] = {}
    end

    -- process the match units in a rule template
    local units = self.rule.units
    for i, unit in ipairs(units) do
        if unit.input then
            table.insert(query_repr.input_schema, unit.input)
            local from, to = matches[i][1], matches[i][2]
            table.insert(query_repr.input_value, question:sub(from, to))
        elseif unit.output then
            table.insert(query_repr.output[1], unit.output)
        else
        end
    end

    -- process the fill section in a rule template
    local fills = self.rule.fills

    for _, fill in ipairs(fills) do
        if fill == ts.FILL_TAGS.COORDINATES then
            table.insert(query_repr.input_schema, qs.POI_ATTR.COORDINATES)
            table.insert(query_repr.input_value, {lng, lat})
        elseif fill == ts.FILL_TAGS.CITY_BY_LNGLAT then
            
        end
    end

    return true
end

-- export symbols
M_.Container = Container
M_.str_starts_with = str_starts_with
M_.str_starts_with_re = str_starts_with_re

return M_
