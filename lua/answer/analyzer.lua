local M_ = {}

local POI_ATTR = {
    NAME = false,
    
    LOCATION = {nil, nil},

    ADDRESS = {
        CITY = false,
        DISTRICT = false,
        STREET = false
    },

    OPEN_TIME = nil,
    PRICE = nil,

    DESC = nil,
}

-- question types
local QTYPE = {
    UNKNOWN = 0,        -- questions that we cannot answer

    SENTIMENTAL = false,
}

-- analyze a question, input the question string, and longitude and latitude in float numbers
--  @question a string of question
--  @lng longitude of the user's location when sending the query
--  @lat latitude of the user's location when sending the query
--
--  @return a question analysis report
--
local function analyze(question, lng, lat)
    return {
        errno = 0,
        errmsg = '',
        qtype = QTYPE.UNKNOWN,
        pos = {},
        parse = {},
        depparse = {},
    }
end

-- export symbols
M_.QTYPE = QTYPE
M_.analyze = analyze

return M_


