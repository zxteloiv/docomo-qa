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

    CLASS = 30,

    -- the tags could be anything that describes the entity
    TAG = 40,

    DESC = 100,

    HEAD_PERSON = 101, -- the leader of this place, e.g. director of a museum

    GENERAL = 255
}

-- enum of available PERSON attributes
local PERSON_ATTR = {
    NAME = 0,
    SEX = 1,
    HOMETOWN = 2,
    AGE = 3,

    GENERAL = 255
}

-- define the searching index
--
local DOWNSTREAM = {
    BAIDU_MAP = 0,
    DOCOMO = 1,
}

-- question representation class
--
local QueryRepr = {}
setmetatable(QueryRepr, { __call = function(cls) return cls.new() end })

QueryRepr.__index = QueryRepr
QueryRepr.new = function()
    local self = {
        qtype = QTYPE.PIPELINE,

        input_schema = {},  -- {POI_ATTR.NAME, POI_ATTR.city}
        input_value = {},   -- {"Forbidden City", "Beijing"}
        output = {},        -- {{POI_ATTR.ADDRESS}, {POI_ATTR.NAME}, ...}

        -- in case of complex questions
        input_pipe = {},

        -- a simple mechanism to indicate whether a question as a whole contains
        -- sentiment, a value with larger integer means more sentiment
        sentiment = 0,

        -- default to use BaiduMap (0), but will be overwritten later in template
        downstream = DOWNSTREAM.BAIDU_MAP,
    }
    setmetatable(self, QueryRepr)
    return self
end

function QueryRepr:set_qtype (qtype) self.qtype = qtype end
function QueryRepr:add_input (schema, value)
    table.insert(self.input_schema, schema)
    table.insert(self.input_value, value)
end
function QueryRepr:reset_input ()
    self.input_schema = {}
    self.input_value = {}
end
function QueryRepr:add_output_pipe (output_data)
    if type(output_data) == "table" then
        table.insert(self.output, output_data)
    end
end
function QueryRepr:add_output_at_pos (attr, pos)
    table.insert(self.output[pos], attr)
end

-- export symbols
M_.QueryRepr = QueryRepr
M_.QTYPE = QTYPE
M_.POI_ATTR = POI_ATTR
M_.PERSON_ATTR = PERSON_ATTR
M_.DOWNSTREAM = DOWNSTREAM

return M_
