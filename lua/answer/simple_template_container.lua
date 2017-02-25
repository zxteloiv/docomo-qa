local M_ = {}

local ts = require("./lua/answer/template_schema")
local qs = require("./lua/answer/query_schema")
local json = require("rapidjson")

local trie_client = require("./lua/utils/tis_client")

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

    for i = 1, len do           -- index on pattern
        local j = i + from - 1  -- the index on string
        if not str:byte(j) or str:byte(j) ~= pattern:byte(i) then
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

local make_iterator = function (func, str, pattern, from)
    local executed = false
    return function ()
        if not executed then executed = true return func(str, pattern, from) end
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
        iter = trie_client.make_tis_iter(question, unit.content, pos)
    end

    return iter
end

Container.gmatch = function (self, question, pos)
    local rule = self.rule
    local matches = {}
    local iter_stack = {}
    local iter_start_pos = {}
    local iter = self:make_universal_iter(question, rule.units[1], pos)
    table.insert(iter_stack, iter)
    table.insert(iter_start_pos, pos)

    return function () 
        while #iter_stack > 0 do
            -- get the tail iterator and retrieve next match
            local iter = iter_stack[#iter_stack]
            local from, to = iter()

            if not from or not to then
                -- the last iterator cannot match anything further
                table.remove(iter_stack, #iter_stack)
                local pos = iter_start_pos[#iter_start_pos]
                if not pos then break end -- first iter is removed
                table.remove(iter_start_pos, #iter_start_pos)

                -- for fuzzy match only, the poped-out iterator could be explored
                -- one more characher on the right
                if rule.match_type == ts.MATCH_TYPE.FUZZY and pos < #question then
                    iter = self:make_universal_iter(question,
                        rule.units[#iter_stack + 1], pos + 1)
                    table.insert(iter_stack, iter)
                    table.insert(iter_start_pos, pos + 1)
                end
            else
                matches[#iter_stack] = {from, to}

                if #iter_stack < #(rule.units) then
                    iter = self:make_universal_iter(question,
                        rule.units[#iter_stack + 1], to + 1)
                    table.insert(iter_stack, iter)
                    table.insert(iter_start_pos, to + 1)
                else
                    return matches
                end
            end
        end

        return nil
    end
end

function Container:set_repr_by_match (query_repr, matches, lng, lat)
    -- by default, assume the pipeline has only 1 element
    if not query_repr.output[1] then
        query_repr.output[1] = {}
    end

    -- process the match units in a rule template
    local units = self.rule.units
    for i, unit in ipairs(units) do
        if unit.input then
            table.insert(query_repr.input_schema, unit.input)
            table.insert(query_repr.input_value, matches[i])
        end
        if unit.output then
            table.insert(query_repr.output[1], unit.output)
        end
    end

    if self.rule.output_pipe then
        query_repr.output = self.rule.output_pipe
    end

    if self.rule.input_pipe then
        query_repr.input_pipe = self.rule.input_pipe
        for i, _ in ipairs(query_repr.input_pipe) do
            query_repr.input_pipe[i].value = {}
            for _, unit in ipairs(query_repr.input_pipe[i].match_units) do
                table.insert(query_repr.input_pipe[i].value, matches[unit])
            end
        end
    end

    -- process the fill section in a rule template
    local fills = self.rule.fills

    if fills then for _, fill in ipairs(fills) do
        if fill == ts.FILL_TAGS.COORDINATES then
            table.insert(query_repr.input_schema, qs.POI_ATTR.COORDINATES)
            table.insert(query_repr.input_value, {lng, lat})
        elseif fill == ts.FILL_TAGS.CITY_BY_LNGLAT then
            local res = ngx.location.capture('/api/geo/reversegeocoding', {
                args = {
                    lng = lng,
                    lat = lat,
                },
            })

            if res and res.status == 200 and res.body then
                local geoinfo = json.decode(res.body)

                if geoinfo.errno == 0 and geoinfo.data and geoinfo.data.city then
                    local city = geoinfo.data.city
                    table.insert(query_repr.input_schema, qs.POI_ATTR.CITY)
                    table.insert(query_repr.input_value, city)
                end
            end
        end
    end end

    -- specify the downstream if any
    if self.rule.downstream then
        query_repr.downstream = self.rule.downstream
    else
        query_repr.downstream = qs.DOWNSTREAM.BAIDU_MAP
    end
end

function Container:choose_matches(iter, question, lng, lat)
    -- find the match that covers the most words in question
    local best_match = nil
    local max_cover = 0
    while true do 
        local next_match = iter()
        if not next_match then break end

        local cover = 0
        for i, val in ipairs(next_match) do
            local from, to = next_match[i][1], next_match[i][2]
            -- ngx.say(from, " ", to, ": ", question:sub(from, to)) -- debug
            cover = cover + (to - from + 1)
        end
        -- ngx.say(cover, "\t", max_cover) -- debug
        if cover > max_cover then
            best_match = json.decode(json.encode(next_match)) -- dirty deepcopy
            max_cover = cover
        end
    end

    -- ngx.say("===> return " .. json.encode(best_match), " m=", max_cover) -- debug
    return best_match, max_cover
end

function Container:run (query_repr, question, lng, lat)
    local iter = self:gmatch(question, 1)

    local matches, max_cover = self:choose_matches(iter, question, lng, lat)
    if not matches then return 0 end

    -- matches refinement,
    -- change matches structure from index pair to the matched strings themselves
    for i, val in ipairs(matches) do
        local from, to = matches[i][1], matches[i][2]
        matches[i] = question:sub(from, to)
    end

    -- match completed, set the representation
    self:set_repr_by_match(query_repr, matches, lng, lat)
    return max_cover * 1.0 / string.len(question)
end

-- export symbols
M_.Container = Container
M_.str_starts_with = str_starts_with
M_.str_starts_with_re = str_starts_with_re

return M_
