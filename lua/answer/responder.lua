local M_ = {}

-- answer a question based on its analysis result and user's location
--
--  @analysis a dict output from query analyzer
--  @lng longitude of user's current location
--  @lat latitude of user's current location
--
--  @return an answer dict
--
local function answer(analysis, lng, lat)
    return {
        errno = 0,
        errmsg = '',
        data = {},
        reprtype = {
        }
    }
end

-- export symbols
M_.answer = answer
return M_
