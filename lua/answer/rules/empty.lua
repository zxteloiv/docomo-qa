local RULE_ = {}

RULE_.match = function (question, query_repr) 
    ngx.say("in empty rule")
    return true
end

return RULE_
