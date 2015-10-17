local p=require"pinout"
local http_util=require"http_util"
local schedule=require"schedule"

local function cycle_gpio(index,transient_state,delay)
    local old_state=gpio.read(index)
    if old_state~=transient_state then
        gpio.write(index,1-old_state)
        schedule(delay*1000,gpio.write,index,old_state)
    end
end

return function(state,send,data,idx)
    local function cycle(send,args)
        if type(args)~="table" or #args~=2 or type(args[1])~="number" or type(args[2])~="number" then
            return 400,nil,"[transient_state(0 or 1),delay(number)] expected"
        end
        if idx then
            cycle_gpio(idx,args[1],args[2])
        else
            for i,v in ipairs(p.output) do
                cycle_gpio(v,args[1],args[2])
            end
        end
        return 204
    end
    if idx then
        idx=tonumber(idx)
        idx=idx and p.output[idx+1]
        if not idx then
            return 404
        end
    end
    return http_util.make_json_receiver(cycle)(send,data)
end
