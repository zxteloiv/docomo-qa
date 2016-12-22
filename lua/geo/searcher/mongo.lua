local M_ = {}

local json = require("rapidjson")

local search_baidu_by_name = function (name)
    local res = ngx.location.capture('/api/external/poi_mongo', {
        method = ngx.HTTP_POST,
        args = {
            dbname = "poi_db",
            colname = "bd_search",
            limit = 3,
        },

        body = json.encode({ name = name })
    })

    if res.status ~= ngx.HTTP_OK then return nil end
    local docs = json.decode(res.body)
    if not docs then return nil end

    return docs
end

local function search_primitive_predicate(func) 
    local res = ngx.location.capture('/api/external/poi_mongo', {
        method = ngx.HTTP_POST,
        args = {
            dbname = "poi_db",
            colname = "predicate_mapper",
            limit = 3,
        },
        body = json.encode({src = func})
    })
    if res.status ~= ngx.HTTP_OK then return {} end
    local docs = json.decode(res.body)
    if not docs then return {} end

    table.sort(docs, function(a, b) -- reversed
        if a.score and b.score then return a.score > b.score else return true end
    end)

    local primitives = {}
    for i, doc in ipairs(docs) do
        table.insert(primitives, doc.dest)
    end

    return primitives
end

-- export symbols
--
M_.search_baidu_by_name = search_baidu_by_name
M_.search_primitive_predicate = search_primitive_predicate

return M_
