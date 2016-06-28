local json = require("rapidjson")
local srv_conf = require("./lua/utils/conftool").load_srv_conf()

-- input parameters
local GET = ngx.req.get_uri_args()
local lng, lat = GET.lng, GET.lat
local is_poi_needed = GET.poi
local maptype = GET.maptype

-- parameter calibration
if not maptype then
    maptype = "baidu"
end
if not is_poi_needed or is_poi_needed == "0" then
    is_poi_needed = false
else
    is_poi_needed = true
end

-- reverse geocoding using baidu service
--
--  @lng longitude in bd09ll system
--  @lat latitude in bd09ll system
--
--  @return baidu result table if success, otherwise nil is returned
--      the table has the following keys
--      * city, the city name of the coordinates
--      * district, the district in that city
--      * street, the street of the coordiates
--      * pois, a list of poi, where each poi is
--          * name, the name of the POI
--          * addr, the addr of the POI
--          * poi_type, the type of the POI
--          * lng, the longitude of the POI, in bd09ll
--          * lat, the latitude of the POI, in bd09ll
--
local function baidu_reversegeocoding(lng, lat, is_poi_needed)
    -- "http://api.map.baidu.com/geocoder/v2/?location=39.983424,116.322987&output=json&pois=1&ak={yourAPIKey}"

    local res = ngx.location.capture('/api/external/wolf_reversegeocoding', {
        args = {
            location = lat .. "," .. lng,
            output = "json",
            pois = (is_poi_needed and 1 or 0),
            ak = srv_conf.baidu_ak
        },
    })

    if not res or not res.status or res.status ~= 200 or not res.body then
        return nil
    end

    local baidu_raw_res = json.decode(res.body)
    -- returned value validation
    if not baidu_raw_res or not baidu_raw_res.status or not baidu_raw_res.result then
        return nil
    end

    -- returned value semantic check
    if baidu_raw_res.status ~= 0 or not baidu_raw_res.result.addressComponent then
        return nil
    end

    -- reconstruct the data structure to return
    local rtn = {
        city = baidu_raw_res.result.addressComponent.city,
        district = baidu_raw_res.result.addressComponent.district,
        street = baidu_raw_res.result.addressComponent.street,
    }

    if is_poi_needed then
        rtn.pois = {}
        for _, poi in pairs(baidu_raw_res.result.pois) do
            table.insert(rtn.pois, {
                name = poi.name,
                addr = poi.addr,
                poi_type = poi.tag,
                lng = poi.point.x,
                lat = poi.point.y,
            })
        end
    end

    return rtn
end


local rtn = {errno = 0, errmsg = "success", data = {}, src = ""}

local baidu_result = baidu_reversegeocoding(lng, lat, is_poi_needed)

if not baidu_result then
    rtn.errno = 1
    rtn.errmsg = "failed to call baidu result"
else
    rtn.data = baidu_result
    rtn.src = "baidu"
end

ngx.say(json.encode(rtn, {pretty = false}))

