local M_ = {}
setmetatable(M_, {
    __call = function (cls)
        return cls.new()
    end
})

M_.__index = M_
M_.new = function ()
    local self = {root = {}}
    setmetatable(self, M_)
    return self
end

function M_:add (key)
    local p = self.root

    local iter, err = ngx.re.gmatch(key, ".", "jou")
    assert(not err, "failed to use RE pattern on the string")

    local m, err = iter()
    while not err and m do
        local u_char = m[0]
        if not p[u_char] then
            p[u_char] = {}
        end
        p = p[u_char]

        m, err = iter()
    end

    p.__val = 1
end

function M_:get (key)
    local p = self.root

    local iter, err = ngx.re.gmatch(key, ".", "jou")
    assert(not err, "failed to use RE pattern on the string")

    local m, err = iter()
    while not err and m do
        local u_char = m[0]

        if not p[u_char] then return false end

        p = p[u_char]
        m, err = iter()
    end

    return (p.__val and p.__val == 1)
end

-- gmatch
-- Get an iterator to find all the substrings of the given string that lies in the
-- trie structure.
-- 
--  @str the string to compare with the trie structure
--  @begin the beginning index of the string
--
--  @return return an iterator function of the matched objects.
--      Each time the iterator is called, the beginning and ending indices of 
--      the matched substring will be returned.
--      When no more substring could be found, a pair of (nil, nil) will be returned.
--
function M_:gmatch (str, begin)
    if not begin then begin = 1 end

    local ctx = {pos = begin}
    local p = self.root

    local function iter()
        while true do
            local from, to, err = ngx.re.find(str, ".", "ajou", ctx)
            if err or not from then return nil, nil end

            local u_char = str:sub(from, to)
            if not p[u_char] then return nil, nil end

            p = p[u_char]

            if p.__val and p.__val == 1 then return begin, to end 
        end
    end

    return iter
end

return M_

