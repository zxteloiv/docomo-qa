local json = require("rapidjson")
local srv_conf = require("./lua/utils/conftool").load_srv_conf()

local LOCATION_SEARCH_TYPE = {
    BY_CITY,
    BY_COORDINATES,
}

-- input parameters
local GET = ngx.req.get_uri_args()
local city = GET.city -- search POI in a city

local name = GET.name -- search POI by name

-- search POI by near some place: lat,lng
local near_lng = GET.near_lng
local near_lat = GET.near_lat
local radius = GET.r
if near_lng and near_lat and not radius then
    radius = 2000
end

local search_baidu_place = function ()
    -- input variables adapter for baidu
    local args = {
        page_num = 0,
        ak = srv_conf.baidu_ak,
        scope = 2,
        output = "json",
    }

    if name then
        args.query = name
    end

    if city then
        args.region = city
        args.city_limit = "true"
    elseif near_lng and near_lat then
        args.location = near_lat .. "," .. near_lng
        args.r = radius
    end

    -- call baidu service
    local res = ngx.location.capture('/api/external/wolf_place', {args = args})
    if res.status ~= 200 or not res.body then return nil end

    local res_table = json.decode(res.body)
    if not res_table then return nil end
    if res_table.status ~= 0 or not res_table.results then return nil end

    local rtn = {}
    for _, poi in ipairs(res_table.results) do
        local poi_data = {}
        poi_data.name = poi.name
        poi_data.addr = poi.address
        poi_data.lng = poi.location.lng
        poi_data.lat = poi.location.lat
        poi_data.src = "baidu"

        if poi.detail_info then
            poi_data.rating = poi.detail_info.overall_rating
            poi_data.price = poi.detail_info.price
            poi_data.class = poi.detail_info.tag
            poi_data.url = poi.detail_info.detail_url
        end

        if poi_data.url then
            table.insert(rtn, poi_data)
        end
    end

    return rtn
end

local rtn = {errno = 0, errmsg = "success", data = {}, src = ""}

local baidu_result = search_baidu_place()
if not baidu_result then
    rtn.errno = 1
    rtn.errmsg = "failed to call baidu place search"
else
    rtn.data = baidu_result
    rtn.src = "baidu"
end

ngx.say(json.encode(rtn, {pretty = true}))
    



