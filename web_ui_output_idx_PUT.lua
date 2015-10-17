local p=require"pinout"
local http_util=require"http_util"

return function(state,send,data,idx)
    local function set_value(send,data)
        if data==0 or data==1 then
            if idx then
                gpio.write(idx,data)
            else
                for i,v in ipairs(p.output) do
                    gpio.write(v,data)
                end
            end
            return 204
        else
            return 400,nil,"0 or 1 expected"
        end
    end
    if idx then
        idx=tonumber(idx)
        idx=idx and p.output[idx+1]
        if not idx then
            return 404
        end
    end
    return http_util.make_json_receiver(set_value)(send,data)
end
