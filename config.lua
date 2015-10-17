local default_value_patterns={
    name="DLI PLC49",
    input_name="Input %d",
    output_name="Outlet %d",
    adc_name="ADC %d",
    cycle_time="1",
}

return {
    get_value=function(name,index)
        local ret
        if file.open("config/"..name..(index and "/"..tostring(index) or "")) then
            ret=file.read()
            file.close()
        elseif default_value_patterns[name] then
            ret=default_value_patterns[name]:format(index)
        else
            ret=""
        end
        return ret
    end,
    set_value=function(data,name,index)
        file.open("config/"..name..(index and "/"..tostring(index) or ""),"w")
        file.write(data)
        file.close()
    end
}
