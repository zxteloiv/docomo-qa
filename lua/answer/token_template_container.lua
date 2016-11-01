local M_ = {}

local ts = require("./lua/answer/template_schema")
local qs = require("./lua/answer/query_schema")
local json = require("rapidjson")

local trie_client = require("./lua/utils/tis_client")

local template_container = require("./lua/answer/simple_template_container").Container

local function call_pos_tagger (question)
    local res = ngx.location.capture('/api/text/pos', {
        method = ngx.HTTP_POST,
        body = ngx.encode_args({q = question})
    })
    if not res or res.status ~= 200 then return nil end
    local res = json.decode(res)
    if not res or res.errno ~= 0 then return nil end

    return res.data
end

local function compare_unit_and_term (unit, term)
    local token, pos = term.token, term.pos

    if unit.tag == ts.UNIT_TYPE.TEXT and unit.content == token then
        return true
    elseif unit.tag == ts.UNIT_TYPE.RE then
        if ngx.re.match(token, unit.content, "ajou") then
            return true
        end
    elseif unit.tag == ts.UNIT_TYPE.DICT then
        local arr = tis_client.call_tis(token, unit.content, 1)
        if #arr > 0 then
            return true
        end
    elseif unit.tag == ts.UNIT_TYPE.POS then
        if unit.content == pos then
            return true
        end
    elseif unit.tag == ts.UNIT_TYPE.POSDICT then
        local arr = tis_client.call_tis(pos, unit.content, 1)
        if #arr > 0 then
            return true
        end
    end

    return false
end

Container.find_match = function (self, question)
    local rule = self.rule
    local terms = call_pos_tagger(question)
    local matches = {}

    local i = 1;

    for _, term in ipairs(tokens) do
        local unit = rule.units[i]

        if compare_unit_and_term(unit, term) then
            table.insert(matches, term.token)
        else
            -- any mismatch means the template failed to match.
            return nil
        end
        
        i = i + 1
    end

    return matches
end

function Container:run (query_repr, question, lng, lat)
    local match = self:find_match(question)
    if not match then return false end

    self:set_repr_by_match(query_repr, match, lng, lat)
    return true
end

-- export symbols
M_.Container = Container

return M_

