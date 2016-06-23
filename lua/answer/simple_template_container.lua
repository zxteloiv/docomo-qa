local Container = setmetatable({}, {
    __call = function (cls, template)
        return cls.new(template)
    end,
})

Container.match = function()
    assert(false, "container should not run directly")
end

Container.__index = Container
Container.new = function(template)
    local self = { rule = template }
    setmetatable(self, Container)
    return self
end

function Container:run (query_repr, question, lng, lat)
    return true
end

return Container
