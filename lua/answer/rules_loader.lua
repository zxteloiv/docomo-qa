local M_ = {}

local rule_list_debug = {
    -- test
    { "geokb", "placeholder", "" },
}

local rule_list = {
    -- each line contains: subsearcher_route, search_type, search_subtype
    
    -- exact search on solr
    -- 国家图书馆 的 创建时间 是
    { "rule", "tpl", "poi-generalFunc"},
    -- what is the creating time of sth.
    { "rule", "tpl", "en_poi-predicate"},

    -- search on baidumap
    -- 酒店 怎么走
    { "rule", "tpl", "loc_category-func"},
    -- 公园
    { "rule", "tpl", "loc_category"},
    -- 哪里有 酒店
    { "rule", "tpl", "loc_func-category"},
    -- 附近 哪里有 公园
    { "rule", "tpl", "loc_near-func-category"},
    -- 附近 的 公园 怎么走
    { "rule", "tpl", "loc_near-category-func"},
    -- 附近 哪里有 兰州拉面
    { "rule", "tpl", "loc_near-func-poi"},
    -- 景山公园 在哪里
    { "rule", "tpl", "loc_poi-func"},
    -- 怎么去 景山公园
    { "rule", "tpl", "loc_func-poi"},
    -- ... 怎么去 ... 国家博物馆 ...
    { "rule", "tpl", "loc-en-fuzzy_func-poi"},
    -- 回龙观
    { "rule", "tpl", "loc_poi"},

    -- general search on solr
    -- where is 紫禁城 .{3,}
    { "rule", "tpl", "loc-en-fuzzy_func-text"},
    -- ... 有哪些 ... 5A级景区 ...
    { "rule", "tpl", "loc-en-fuzzy_func-tag"},
    -- ... 国家图书馆 ... 创建时间 ...
    { "rule", "tpl", "loc-fuzzy_poi-func"},
    -- ... hometown ... director ... National Library
    { "rule", "tpl", "loc-en_loc-person-poi"},


    -- curated GeoKB subsearcher
    { "geokb", "", "" },

    { "rule", "func", "empty_runner" }
}

-- export symbols
M_.rule_list = rule_list

return M_

