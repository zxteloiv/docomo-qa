
local a = true
local b = false

local s = (a and "a is true" or "a is false")
ngx.say(s)
local s = (b and "b is true" or nil)
ngx.say(s)


