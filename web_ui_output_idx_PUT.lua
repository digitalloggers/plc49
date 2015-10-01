local p=require"pinout"
local http_util=require"http_util"

return function(state,s,data,idx)
    idx=p.output[tonumber(idx)+1]

    if idx then
        local function set_value(s,data)
            if data==0 or data==1 then
                gpio.write(idx,data)
                return 204
            else
                return 400,nil,"0 or 1 expected"
            end
        end
        return http_util.make_json_receiver(set_value)(s,data)
    else
        return 404
    end
end
