local http_util=require"http_util"
local config=require"config"

return function(state,s,data,name,index)
    return http_util.reply_json(s,config.get_value(name,index and (tonumber(index)+1)))
end
