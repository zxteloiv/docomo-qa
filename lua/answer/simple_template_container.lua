local M_ = {}

local ts = require("./lua/answer/template_schema")
local qs = require("./lua/answer/query_schema")

-- match type text
-- Check if the string matches the text pattern, for the best performance
--
--  @str the input string
--  @pattern the pattern to compare with
--  @from the position index to start to compare, default to 1 if not given
--
--  @return a pair of start and ending position of the matched part.
--     If the pattern is not matched, two 0 will be returned.
--
local str_starts_with = function (str, pattern, from)
    if not from then from = 1 end -- if from is missing, start from the beginning
    if not str or not pattern then return 0, 0 end
    local len = #pattern
    if len == 0 then return 0, 0 end

    for i = from, len do
        if not str:byte(i) or str:byte(i) ~= pattern:byte(i) then
            return 0, 0
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
--     If the pattern is not matched, two 0 will be returned.
--
local str_starts_with_re = function (str, pattern, from)
    if not str or not pattern then return 0, 0 end
    if #str == 0 or #pattern == 0 then return 0, 0 end

    local ctx = {pos = from}
    local from, to, err = ngx.re.find(str, pattern, "ajou", ctx)

    if from then
        return from, to
    else
        return 0, 0
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

function Container:run (query_repr, question, lng, lat)
    return true
end

-- export symbols
M_.Container = Container
M_.str_starts_with = str_starts_with
M_.str_starts_with_re = str_starts_with_re

return M_
