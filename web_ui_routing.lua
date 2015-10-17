-- Packed list of tuples to save memory size
local routing_table={
    "/state",                    "web_ui_state",
    "/state/all/all/value",      "web_ui_state_values",
    "/state/input",              {"web_ui_input",       false},
    "/state/input/(%d+)",        {"web_ui_input",       false},
    "/state/input/(%d+)/name",   {"web_ui_str",         "input_name"},
    "/state/input/(%d+)/value",  {"web_ui_input",       "value"},
    "/state/input/all/name",     {"web_ui_input",       "name"},
    "/state/input/all/value",    {"web_ui_input",       "value"},
    "/state/output",             {"web_ui_output",      false},
    "/state/output/(%d+)",       {"web_ui_output",      false},
    "/state/output/(%d+)/name",  {"web_ui_str",         "output_name"},
    "/state/output/(%d+)/value", "web_ui_output_idx",
    "/state/output/(%d+)/cycle", "web_ui_output_cycle",
    "/state/output/all/name",    {"web_ui_output",      "name"},
    "/state/output/all/value",   "web_ui_output_idx",
    "/state/output/all/cycle",   "web_ui_output_cycle",
    "/state/adc",                {"web_ui_adc",         false},
    "/state/adc/(%d+)",          {"web_ui_adc",         false},
    "/state/adc/(%d+)/name",     {"web_ui_str",         "adc_name"},
    "/state/adc/(%d+)/value",    {"web_ui_adc",         "value"},
    "/state/adc/all/name",       {"web_ui_adc",         "name"},
    "/state/adc/all/value",      {"web_ui_adc",         "value"},

    "/config",                   "web_ui_config",
    "/config/name",              {"web_ui_str",         "name"},
    "/config/cycle_time",        {"web_ui_str",         "cycle_time"},
    "/config/wifi_mode",         "web_ui_wifi_mode",
    "/config/wifi_ap",           {"web_ui_wifi_config", "ap"},
    "/config/wifi_sta",          {"web_ui_wifi_config", "sta"},

    "/eval",                     "web_ui_eval",

    "(%S+)",                     {"web_ui_static",      "www/static"}
}

return function(state,data)
    local method,url=data:match("^(%S*) (%S*) .*")
    if method and url then
        local handler,arguments
        local query_param_pos=url:find('?')
        if query_param_pos then
            -- TODO: We aren't using query parameters anywhere, so we discard them
            url=url:sub(1,query_param_pos-1)
        end
        for i=1,#routing_table,2 do
            arguments={string.match(url,"^"..routing_table[i].."$")}
            if #arguments>0 then
                -- Handlers with no captures receive no extra arguments
                if #arguments==1 and arguments[1]==url and not routing_table[i]:find("%(") then
                    arguments[1]=nil
                end
                handler=routing_table[i+1]
                if type(handler)=="table" then
                    for i=2,#handler do
                        table.insert(arguments,i-1,handler[i])
                    end
                    handler=handler[1]
                end
                break
            end
        end
        if handler then
            if file.open(handler.."_"..method..".lua") or file.open(handler.."_"..method..".lc") then
                file.close()
                return handler.."_"..method,arguments or {}
            else
                return 405
            end
        else
            return 404
        end
    else
        return 400
    end
end
