local dicts = {
    place = "./assets/poi.example.dict",
    func = "./assets/location.func.example.dict",
}

local g_shared_ro = {}

local trie = require("./lua/utils/trie")

local load_dict = function (dict_name)
    local dict_path = dicts[dict_name]
    if not dict_path then ngx.say(dict_name, ' does not exist.') return end

    ngx.say("loading ", dict_name, ' from ', dict_path)

    local fp = io.open(dict_path, 'r')
    local t = trie()
    for line in fp:lines() do
        t:add(line)
    end

    g_shared_ro[dict_name] = t

    fp:close()
end

local init_global = function ()
    -- load dict files
    for dict_name, dict_path in pairs(dicts) do
        load_dict(dict_name)
    end
end

init_global()

return g_shared_ro

