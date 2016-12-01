local M_ = {}

local json = require("rapidjson")
local srv_conf = require("./lua/utils/conftool").load_srv_conf()

local search_baidu_place = function (args)
    -- input variables adapter for baidu
    local url_args = {
        page_num = 0,
        ak = srv_conf.baidu_ak,
        scope = 2,
        output = "json",
    }

    if args.name then
        url_args.query = args.name
    end

    if args.city then
        url_args.region = args.city
        url_args.city_limit = "true"
    elseif args.near_lng and args.near_lat then
        url_args.location = args.near_lat .. "," .. args.near_lng
        url_args.r = args.radius
    end

    -- call baidu service
    local res = ngx.location.capture('/api/external/wolf_place', {args = url_args})
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
            poi_data.phone = poi.telephone
            poi_data.class = poi.detail_info.tag
            poi_data.url = poi.detail_info.detail_url
        end

        if poi_data.url then
            table.insert(rtn, poi_data)
        end
    end

    return rtn
end

M_.search_baidu_place = search_baidu_place
return M_

