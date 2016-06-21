local M_ = {}

-- template schema specification
--

-- A template contains several rules, each of which could be in two types.
-- If a rule is activated, the system should either ACCEPT or REJECT the question.
local RULE_TYPE = {
    ACCEPT = 0,
    REJECT = 1,
}

-- Match unit types of a rule
-- Each match unit could be a plain TEXT, a Regular Expression or a DICTionary.
local MATCH_UNIT_TYPE = {
    TEXT = 0,
    RE = 1,
    DICT = 2
}

-- Available tags that can be filled into a request
--
local FILL_TAGS = {
    IP = 0,
    LNG = 1,
    LAT = 2,
}

-- export symbols
--
M_.RULE_TYPE = RULE_TYPE
M_.MATCH_UNIT_TYPE = MATCH_UNIT_TYPE

return M_
