local json = require("rapidjson")
local srv_conf = require("./lua/utils/conftool").load_srv_conf()
local url = require("./lua/utils/url")

-- input parameters
local GET = ngx.req.get_uri_args()
local city = GET.city
local name = GET.name
local maptype = GET.maptype

-- parameter calibration
if not maptype then
    maptype = "baidu"
end

-- call baidu geocoding
--
--  @city the city name in UTF-8 string
--  @name the name or address of POI to do geocoding
--
--  @return baidu result table if success, otherwise nil is returned
--          the table has the following keys
--          * lng, the longitude of the requested POI, in bd09ll
--          * lat, the latitude of the requested POI, in bd09ll
--
local function baidu_geocoding(city, name)
    local res = ngx.location.capture('/api/external/wolf_geocoding', {
        args = {
            output = "json",
            address = name,
            city = city,
            ak = srv_conf.baidu_ak
        },
    })

    if not res or not res.status or res.status ~= 200 or not res.body then
        return nil
    end

    local baidu_raw_res = json.decode(res.body)
    if not baidu_raw_res or baidu_raw_res.status ~= 0 or not baidu_raw_res.result.location then
        return nil
    end

    local rtn = {
        lng = baidu_raw_res.result.location.lng,
        lat = baidu_raw_res.result.location.lat,
    }

    return rtn
end

local rtn = {errno = 0, errmsg = "success", data = {}, src = ""}

local baidu_result = baidu_geocoding(city, name)

if not baidu_result then
    rtn.errno = 1
    rtn.errmsg = "failed to call baidu service"
else
    rtn.data = baidu_result
    rtn.src = "baidu"
end

ngx.say(json.encode(rtn, {pretty = true}))

