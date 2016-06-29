local M_ = {}

function decode(str)
    str = string.gsub (str, "+", " ")
    str = string.gsub (str, "%%(%x%x)", function(h)
        return string.char(tonumber(h,16))
    end)
    str = string.gsub (str, "\r\n", "\n")
    return str
end

function encode(str)
    if (str) then
        str = string.gsub (str, "\n", "\r\n")
        str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
        str = string.gsub (str, " ", "+")
    end
    return str    
end

-- export symbols
M_.decode = decode
M_.encode = encode

return M_
