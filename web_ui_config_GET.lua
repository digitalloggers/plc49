local http_util=require"http_util"
local config=require"config"

local mode_map={
    [wifi.SOFTAP]="ap",
    [wifi.STATION]="sta",
    [wifi.STATIONAP]="sta+ap"
}

return function(state,s,data)
    -- XXX: Working around https://github.com/elua/elua/issues/69
    local ap_ssid,ap_password=wifi.ap.getconfig()
    local sta_ssid,sta_password=wifi.sta.getconfig()
    return http_util.reply_json(s,{name=config.get_value("name"),wifi_mode=mode_map[wifi.getmode()],wifi_ap={ap_ssid,ap_password},wifi_sta={sta_ssid,sta_password}})
end
