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

-- question types
-- Since each query is a single question and no more instance is required, 
-- we choose to use an object instance rather than an all-round class here.
local query_struct = {
    qtype = QTYPE.PIPELINE,

    input = {POI_ATTR.NAME, POI_ATTR.CITY},
    output = {{POI_ATTR.ADDRESS}},

    -- a simple mechanism to indicate whether a question as a whole contains
    -- sentiment, a value with larger integer means more sentiment
    sentiment = 0,
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


