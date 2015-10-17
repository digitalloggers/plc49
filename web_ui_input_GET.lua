local p=require"pinout"
local config=require"config"
local http_util=require"http_util"

local function name(idx)
    return config.get_value("input_name",idx)
end

local function value(idx)
    local v=p.input[idx]
    return 1-gpio.read(v)
end

local item_functions={
    [false]=function(idx)
        return {name=name(idx),value=value(idx)}
    end,
    name=name,
    value=value
}

return function(state,send,data,field,idx)
    idx=idx and tonumber(idx)+1
    local ret
    local item_function=item_functions[field]
    if idx then
        if not p.input[idx] then
            return 404
        end
        ret=item_function(idx)
    else
        ret={}
        for i,v in ipairs(p.input) do
            ret[i]=item_function(i)
            tmr.wdclr()
        end
    end
    return http_util.reply_json(send,ret)
end
