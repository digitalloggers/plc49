local p=require"pinout"

local gpio_pullup_override ={
    -- GPIO2 needs to float
    [4]=gpio.FLOAT
}

for _,v in ipairs(p.input) do
    gpio.mode(v,gpio.INPUT,gpio_pullup_override[v] or gpio.PULLUP)
end
for _,v in ipairs(p.output) do
    gpio.mode(v,gpio.OUTPUT)
end
