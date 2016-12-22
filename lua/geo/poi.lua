local json = require("rapidjson")

local search_baidu_place = require("./lua/geo/searcher/baidu").search_baidu_place
local solr = require("./lua/geo/searcher/solr")

local LOCATION_SEARCH_TYPE = {
    BY_CITY,
    BY_COORDINATES,
}

-- input parameters processing
--

local GET = ngx.req.get_uri_args()
local downstream = GET.downstream -- search downstream, either baidu or solr
if not downstream then
    downstream = "baidu"
end
-- search POI by near some place: lat,lng
local radius = GET.r
if GET.near_lng and GET.near_lat and not radius then
    radius = 2000
end

local args = {
    name = GET.name, city = GET.city, tag = GET.tag, func = GET.func,
    near_lng = GET.near_lng, near_lat = GET.near_lat, radius = raidus
}

-- ngx.say(json.encode(args)) -- debug

-- do the search job

if downstream == "baidu" then

    local rtn = {errno = 0, errmsg = "success", data = {}, src = ""}

    local baidu_result = search_baidu_place(args)
    if not baidu_result then
        rtn.errno = 1
        rtn.errmsg = "failed to call baidu place search"
    else
        rtn.data = baidu_result
        rtn.src = "baidu"
    end

    ngx.say(json.encode(rtn, {pretty = true}))

elseif downstream == "solr" then

    local solr_result = solr.search(args)
    ngx.say(json.encode({errno = 0, errmsg = "success", data = solr_result}))

else
    -- no other type of downstream any more
    ngx.say(json.encode({errno = 1, errmsg = "downstream not supported"}))
end




