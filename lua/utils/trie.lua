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
        local byte = m[0]
        if not p[byte] then
            p[byte] = {}
        end
        p = p[byte]

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
        local byte = m[0]

        if not p[byte] then return false end

        p = p[byte]
        m, err = iter()
    end

    return (p.__val and p.__val == 1)
end

return M_

