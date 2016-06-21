local M_ = {}

-- enum of available question types
local QTYPE = {
    UNKNOWN = 0,        -- questions that we cannot answer
    PIPELINE = 1,       -- a question with a few consequent seaching actions
}

-- enum of available POI attributes
local POI_ATTR = {
    NAME = 0,

    COORDINATES = 1,
    OPEN_TIME = 2,
    PRICE = 3,

    ADDRESS = 20,
    CITY = 21,
    DISTRICT = 22,
    STREET = 23,

    DESC = 100
}

-- question representation
local QueryRepr = {}
QueryRepr.new = function()
    return {
        qtype = QTYPE.PIPELINE,

        input_schema = {POI_ATTR.NAME, POI_ATTR.CITY},
        input_value = {nil, nil},
        output = {{POI_ATTR.ADDRESS}},

        -- a simple mechanism to indicate whether a question as a whole contains
        -- sentiment, a value with larger integer means more sentiment
        sentiment = 0,
    }
end


-- export symbols
M_.QueryRepr = QueryRepr
M_.QTYPE = QTYPE
M_.POI_ATTR = POI_ATTR


return M_
