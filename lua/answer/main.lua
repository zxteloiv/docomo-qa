-- loading dependencies
--
local json = require("rapidjson")
local rule_list = require("./lua/answer/rules_loader").rule_list

-- dispatcher
-- send the single query to all subsearchers
-- Parameters:
--  question: the input query
--  lng: the user longitude
--  lat: the user latitude
--
-- Return:
--  an array table of returned objects of all subsearchers
local function dispatch(rule_list, question, lng, lat)
    local multi_request_args = {}

    for _, r in ipairs(rule_list) do
        local route = r[1]
        local request = { "/answer/subsearcher/" .. route, {args = {}}}
        if route == "rule" then
            request[2].args.req_type = r[2]
            request[2].args[r[2]] = r[3]
            request[2].args.lng = lng
            request[2].args.lat = lat
            request[2].args.q = question
        end

        table.insert(multi_request_args, request)
    end

    -- if true then ngx.say(json.encode(multi_request_args)) return end

    local all_res = { ngx.location.capture_multi(multi_request_args) }

    local doclists = {}

    for _, res in ipairs(all_res) do repeat
        if not res.status == 200 or not res.body then break end
        local rtn = json.decode(res.body)
        if not rtn then break end

        if not rtn.errno == 0 or not rtn.data then break end

        table.insert(doclists, rtn)
    until true end

    return doclists
end

-- blend
-- merge all the doclists returned from various subsearchers and do some ranking.
-- Right now reranking is based on match score * individual doc score
--
-- Parameters:
--  doclists: an array of multiple returned doclist from all subsearchers
--
-- Return:
--  the blended and re-ranked doclist
local function blend(doclists)
    local alldocs = {}
    for _, doclist in ipairs(doclists) do
        local match_score = doclist.match_score
        if #(doclist.data) > 0 then
            local max_score = doclist.data[1].score
            for _, doc in ipairs(doclist.data) do
                if not doc.score then
                    doc.score = 0.5
                else
                    doc.score = doc.score * match_score / max_score
                end
                table.insert(alldocs, doc)
            end
        end
    end

    table.sort(alldocs, function (x, y) return x.score > y.score end)
    return alldocs
end

-- main API function starts here
--

-- process POST arguments
ngx.req.read_body()
local POST = ngx.req.get_post_args()

if not POST.q then
    ngx.redirect('/')   -- redirect to homepage if the primary arg is missing
end

if POST.lng and POST.lat then
    lng, lat = POST.lng, POST.lat
else
    lng = nil
    lat = nil
end

ngx.log(ngx.DEBUG, json.encode(POST))

local doclists = dispatch(rule_list, POST.q, lng, lat) 
local ranked_list = blend(doclists)

local result = {errno = 0, errmsg = 'success', data = ranked_list, reprtype = ""}
ngx.say(json.encode(result))


