ngx.req.read_body()
local POST = ngx.req.get_post_args()
local rapidjson = require("rapidjson")

if POST.q then
    query = POST.q

    local res = ngx.location.capture(
        '/api/external/jieba',
        {
            method = ngx.HTTP_POST,
            args = { method = "HMM", format = "simple" },
            body = query
        }
    )

    local split = require("split")
    
    if not res.truncated then
        rtn = {
            errno = 0,
            data = split.split(res.body, ' ')
        }

        ngx.say(rapidjson.encode(rtn))
    else
        ngx.say(rapidjson.encode({
            errno = 2,
            errmsg = "failed to access seg micro-service"
        }))
    end
    return
else
    ngx.say(rapidjson.encode({
        errno = 1,
        errmsg = "post parameter error"
    }));
end
