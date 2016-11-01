local M_ = {}

-- template schema specification
--

-- A template contains several rules, each of which could be in two types.
-- If a rule is activated, the system should either ACCEPT or REJECT the question.
local RULE_TYPE = {
    ACCEPT = 0,
    REJECT = 1,
}

-- Match Type
-- the rule of matching could be either exact match, or fuzzy match.
-- A fuzzy match will ignore the preceeding terms if they doesn't match the rule,
-- while an exact match doesn't.
local MATCH_TYPE = {
    EXACT = 0,
    FUZZY = 1
}

-- Match unit types of a rule
-- Each match unit could be a plain TEXT, a Regular Expression or a DICTionary.
local UNIT_TYPE = {
    TEXT = 0,
    RE = 1,
    DICT = 2,
    POS = 3
}

-- Available tags that can be filled into a request
--
local FILL_TAGS = {
    IP = 0,
    COORDINATES = 1,

    SERVER_TIME = 2,

    CITY_BY_LNGLAT = 3,
    DISTRICT_BY_LNGLAT = 4,
}

-- export symbols
--
M_.RULE_TYPE = RULE_TYPE
M_.UNIT_TYPE = UNIT_TYPE
M_.MATCH_TYPE = MATCH_TYPE
M_.FILL_TAGS = FILL_TAGS

return M_
