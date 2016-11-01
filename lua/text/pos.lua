ngx.req.read_body()
local POST = ngx.req.get_post_args()
local rapidjson = require("rapidjson")

if POST.q then
    local query = POST.q
    query = ngx.re.gsub(query, "\r|\n", " ", "ju") -- remove all newlines
    
    local res = ngx.location.capture(
        '/api/external/jieba?method=TAG',
        {
            method = ngx.HTTP_POST,
            args = { method = "TAG" },
            body = query
        }
    )

    local split = require("split")

    if res and res.status == 200 and (not res.truncated) then
        -- trim input using re.gsub first
        local lines = split.split(ngx.re.gsub(res.body, '\n$', '', 'ju'), '\n')

        for i, pair in ipairs(lines) do
            token_pos = split.split(lines[i], '\t')
            lines[i] = { token = token_pos[1], pos = token_pos[2] }
        end
        rtn = {
            errno = 0,
            data = lines
        }

        ngx.say(rapidjson.encode(rtn))
    else
        ngx.say(rapidjson.encode({
            errno = 1,
            errmsg = "failed to access cppjieba"
        }))
    end
else
    ngx.say(rapidjson.encode({
        errno = 2,
        errmsg = "post parameter missing for sentence"
    }))
end



