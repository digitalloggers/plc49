local p=require"pinout"

local gpio_floating ={
    -- GPIO2 needs to float
    [4]=true
}

for _,v in ipairs(p.input) do
    local mode
    if gpio_floating[v] then
        mode=gpio.FLOAT
    else
        mode=gpio.PULLUP
    end
    gpio.mode(v,gpio.INPUT,mode)
end
for _,v in ipairs(p.output) do
    gpio.mode(v,gpio.OUTPUT)
end
