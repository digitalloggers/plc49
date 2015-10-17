local p=require"pinout"
local http_util=require"http_util"
local schedule=require"schedule"

local CYCLE_DELAY_MS=1000

local function cycle(idx)
    local old_value=gpio.read(idx)
    gpio.write(idx,1-old_value)
    schedule(CYCLE_DELAY_MS,gpio.write,idx,old_value)
end

return function(state,send,data,idx)
    idx=idx and tonumber(idx)+1
    if idx then
        idx=p.output[idx]
        if idx then
            cycle(idx)
        else
            return 404
        end
    else
        for i,v in ipairs(p.output) do
            cycle(v)
        end
    end
    return 204
end
