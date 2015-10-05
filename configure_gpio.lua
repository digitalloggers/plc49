local p=require"pinout"

for _,v in ipairs(p.input) do
    gpio.mode(v,gpio.INPUT,gpio.FLOAT)
end
for _,v in ipairs(p.output) do
    gpio.mode(v,gpio.OUTPUT)
end
