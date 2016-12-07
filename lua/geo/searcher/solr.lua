local M_ = {}

local json = require("rapidjson")
local mongo = require("./lua/geo/searcher/mongo")

local LOC_ENT_CATEGORY = "/api/external/solr/ent_category"
local LOC_ENT_NAME = "/api/external/solr/ent_name"
local LOC_ENT_PREDICATE = "/api/external/solr/ent_predicate"

-- solr searching common interfaces
--

local extract_solr_result = function (res)
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

local search_solr_with_location_args = function (location, args)
    local url_args = args
    url_args.fl = "*,score"
    url_args.wt = "json"

    local res = ngx.location.capture(location, { args = url_args })
    return extract_solr_result(res)
end

local search_solr_with_query_field = function(location, f, v)
    local url_args = { q = f .. ":" .. v }
    return search_solr_with_location_args(location, url_args)
end

-- search the ent_category core
--
local search_id_by_category = function (cat)
    return search_solr_with_query_field(LOC_ENT_CATEGORY, "category", cat)
end

local search_category_by_id = function (id)
    return search_solr_with_query_field(LOC_ENT_CATEGORY, "ent_id", id)
end

-- search the ent_name core
--
local search_name_by_id = function (id)
    return search_solr_with_query_field(LOC_ENT_NAME, "ent_id", id)
end

local search_id_by_name = function (lang, name)
    if lang == "en" or lang == "ja" or lang == "zh" then
        return search_solr_with_query_field(LOC_ENT_NAME, lang, name)
    else
        return nil
    end
end

-- search the ent_predicate core
--
local search_predicate_by_id = function (id)
    return search_solr_with_query_field(LOC_ENT_PREDICATE, "ent_id", id)
end

-- the main API entry
--
local search_by_tag = function (tag, docset)
    local res = search_id_by_category(tag)
    if res and #res > 0 then
        -- add name by ent_id
        -- build urls
        local sub_args = {}
        for i, doc in ipairs(res) do
            table.insert(sub_args, {LOC_ENT_NAME, { args = {
                fl = "*,score",
                wt = "json",
                q = "ent_id:" .. doc.ent_id
            }}})
        end
        local all_res = { ngx.location.capture_multi(sub_args) }
        for i, res in ipairs(all_res) do
            extracted = extract_solr_result(res)
            -- add the first only since unique id is unique, there should be
            -- only one item in the result
            if #extracted > 0 then table.insert(docset, extracted[1]) end
        end
    end
end

local search_by_name = function (name, docset)
    local en_res, zh_res, ja_res = ngx.location.capture_multi({
        { LOC_ENT_NAME, {args = { fl = "*,score", wt = "json", q = "en:" .. name }}},
        { LOC_ENT_NAME, {args = { fl = "*,score", wt = "json", q = "zh:" .. name }}},
        { LOC_ENT_NAME, {args = { fl = "*,score", wt = "json", q = "ja:" .. name }}}
    })

    -- use key-value table in case the null problem in iteration using ipairs
    local extracted = {
        en = extract_solr_result(en_res), 
        zh = extract_solr_result(zh_res), 
        ja = extract_solr_result(ja_res)
    }

    local uniq_set = {}
    for lang, res_set in pairs(extracted) do
        for i, v in ipairs(res_set) do
            if v.ent_id and (not uniq_set[v.ent_id]) then
                uniq_set[v.ent_id] = 1
                table.insert(docset, v)
            end
        end
    end
end

local search = function (args)
    local rtn = {errno = 1, errmsg = "nothing retrieved", data = {}, reprtype = {}}
    local docset = {}
    if args.tag then
        search_by_tag(args.tag, docset)
    elseif args.name then
        search_by_name(args.name, docset)
    end

    -- now in docset: entity_id and entity_name, try to retrieve more data, by name
    for i, ent in ipairs(docset) do repeat

        if not ent.zh then break end
        local res = mongo.search_baidu_by_name(ent.zh)
        if not res then break end

        docset[i].baidu = res[1]

    until true end

    return docset

end

-- export symbols
--
M_.search_predicate_by_id = search_predicate_by_id
M_.search_id_by_category = search_id_by_category
M_.search_category_by_id = search_category_by_id
M_.search_id_by_name = search_id_by_name
M_.search_name_by_id = search_name_by_id

M_.search = search

return M_
