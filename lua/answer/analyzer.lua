local M_ = {}

-- question types
local QTYPE = {
    UNKNOWN = 0,        -- questions that we cannot answer
    POI_BY_NAME = 1,    -- find list of poi by name

    POI_BY_CITY = 100,   -- find list of poi in city
    POI_BY_DISTRICT = 101,   -- find pois in a district
    POI_NEAR_PLACE = 102,  -- find poi near a place name or address

    POI_BY_PRICE = 2,   -- find poi by price
    POI_BY_OFFICE_HOUR = 3, -- find poi by office time

    POI_BY_DESC = 5, -- find poi by description

    POI_BY_FUNCTION = 6, -- find poi by function it has

    ADDR_BY_POI_NAME = 1000,    -- find address by poi name
    PRICE_BY_POI_NAME = 1001,   -- find average cost by poi name

    SENTIMENTAL = 10000,    -- sentimental

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


