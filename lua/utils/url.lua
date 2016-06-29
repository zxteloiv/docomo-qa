local M_ = {}

local function byte2str(h)
    return string.char(tonumber(h,16))
end

function url_decode(str)
    str = string.gsub (str, "+", " ")
    str = string.gsub (str, "%%(%x%x)", byte2str)
    str = string.gsub (str, "\r\n", "\n")
    return str
end

local function str2byte(c)
    return string.format ("%%%02X", string.byte(c))
end

function url_encode(str)
    if (str) then
        str = string.gsub (str, "\n", "\r\n")
        str = string.gsub (str, "([^%w %-%_%.%~])", str2byte)
        str = string.gsub (str, " ", "+")
    end
    return str    
end

-- export symbols
M_.decode = url_decode
M_.encode = url_encode

return M_
