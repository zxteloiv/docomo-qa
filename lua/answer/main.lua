-- loading dependencies
--
local json = require("rapidjson")
local analyzer = require("./lua/answer/analyzer")
local reponder = require("./lua/answer/responder")

-- process POST arguments
--
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

ngx.say("after redirect")

-- answer the query
--
query_analysis = analyzer.analyze(POST.q, lng, lat)

answer = responder.answer(query_analysis, lng, lat)

ngx.say(json.encode(answer))



