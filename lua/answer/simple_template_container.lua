local ts = require("./lua/answer/template_schema")
local qs = require("./lua/answer/query_schema")

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

-- match type text
-- Check if the string matches the text pattern, for the best performance
--
--  @str the input string
--  @pattern the pattern to compare with
--  @from the position index to start to compare, default to 1 if not given
--
--  @return a pair of word and position, if the pattern is matched,
--     the word is the pattern itself and position is the index after the pattern.
--     Otherwise, the returned word is nil and position is 0.
--
local function str_starts_with(str, pattern, from)
    if not from then from = 1 end -- if from is missing, start from the beginning
    local len = #pattern

    local is_matched = true
    for i = from, len do
        if not str.byte[i] or not pattern.byte[i] then
            is_matched = false
            break
        end
        if str.byte[i] ~= pattern.byte[i] then
            is_matched = false
            break
        end
        
    end

    -- this tenary operator trick is tested here only and may not work elsewhere
    local word = (is_matched and pattern or nil)
    local pos = (is_matched and from + len or 0)
    
    return word, pos
    
end

function Container:run (query_repr, question, lng, lat)
    return true
end

return Container
