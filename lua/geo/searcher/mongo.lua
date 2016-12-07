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

-- export symbols
--
M_.search_baidu_by_name = search_baidu_by_name

return M_
