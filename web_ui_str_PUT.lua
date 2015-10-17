local http_util=require"http_util"
local config=require"config"

return function(state,send,data,name,idx)
    local function set_value(send,data)
        if type(data)=="string" then
            config.set_value(data,name,idx and (tonumber(idx)+1))
            return 204
        else
            return 400,nil,"string expected"
        end
    end
    return http_util.make_json_receiver(set_value)(send,data)
end
