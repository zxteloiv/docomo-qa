local M_ = {}

local json = require("rapidjson")

local search_solr = function(location, f, v)
    local url_args = {
        fl = "*,score",
        q = f .. ":" .. v,
        wt = "json",
    }

    local res = ngx.location.capture(location, { args = url_args })
    if res.status ~= 200 or not res.body then return nil end
    res = json.decode(res.body)
    if not res or not res.responseHeader then return nil end
    if res.responseHeader.status ~= 0 then return nil end
    if not res.response or not res.response.docs then return nil end
    if not res.response.maxScore then return nil end

    -- filter strategy
    if res.response.maxScore < 10 then return nil end

    return res.response.docs
end

-- search the ent_category core
--
local search_id_by_category = function (cat)
    return search_solr("/api/external/solr/ent_category", "category", cat)
end

local search_category_by_id = function (id)
    return search_solr("/api/external/solr/ent_category", "ent_id", id)
end

-- search the ent_name core
--
local search_name_by_id = function (id)
    return search_solr("/api/external/solr/ent_name", "ent_id", id)
end

local search_id_by_name = function (lang, name)
    if lang == "en" or lang == "ja" or lang == "zh" then
        return search_solr("/api/external/solr/ent_name", lang, name)
    else
        return nil
    end
end

-- search the ent_predicate core
--
local search_predicate_by_id = function (id)
    return search_solr("/api/external/solr/ent_predicate", "ent_id", id)
end

-- export symbols
--
M_.search_predicate_by_id = search_predicate_by_id
M_.search_id_by_category = search_id_by_category
M_.search_category_by_id = search_category_by_id
M_.search_id_by_name = search_id_by_name
M_.search_name_by_id = search_name_by_id
M_.search_solr = search_solr

return M_
