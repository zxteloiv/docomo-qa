local M_ = {}
local json = require("rapidjson")

-- Call the Trie Index Service
--  @question the input question string
--  @dict the dict tag name
--  @pos the starting index of the question to search 
--
--  @return nil when errors occur, or an array of indices of the ending pos of
--          each valid prefix
local call_tis = function (question, dict, pos)
    -- note the input and output index of TIS is zero-based
    local res = ngx.location.capture('/api/external/tis', {
        args = {
            q = question,
            d = dict,
            offset = pos - 1,
        },
    })

    if not res or res.status ~= 200 or not res.body then return nil end

    res = json.decode(res.body)
    if not res.errno or not res.errmsg then return nil end
    if res.errno ~= 0 then return nil end

    local arr = {}
    for i, v in ipairs(res.data) do
        table.insert(arr, v)
    end

    return arr
end

local make_tis_iter = function (question, dict, pos)
    local arr = call_tis(question, dict, pos)
    if not arr then return function () return nil, nil end end

    local p = 1
    local iter_func = function()
        if not arr[p] then return nil, nil end
        p = p + 1
        return pos, p - 1
    end

    return iter_func
end


-- export symbols
M_.call_tis = call_tis
M_.make_tis_iter = make_tis_iter

return M_
