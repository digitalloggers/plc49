local p=require"pinout"
local http_util=require"http_util"

return function(state,s,data)
    idx=idx and tonumber(idx)+1
    local inputs={}
    local outputs={}
    local adcs={}
    for i,v in ipairs(p.input) do
        inputs[i]=1-gpio.read(v)
        tmr.wdclr()
    end
    for i,v in ipairs(p.output) do
        outputs[i]=gpio.read(v)
        tmr.wdclr()
    end
    for i,v in ipairs(p.adc) do
        adcs[i]={adc.read(v[1]),v[2]}
        tmr.wdclr()
    end
    return http_util.reply_json(s,{input=inputs,output=outputs,adc=adcs})
end
