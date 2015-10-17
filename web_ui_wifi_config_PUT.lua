local http_util=require"http_util"

return function(state,send,data,kind)
    local function set_config(send,data)
        if type(data)=="table" and #data==2 then
            local mode=wifi.getmode()
            if kind=="ap" then
                if mode==wifi.STATION then
                    wifi.setmode(wifi.STATIONAP)
                end
                -- XXX: interface differs from wifi.sta.config
                wifi.ap.config({ssid=data[1],pwd=data[2],auth=wifi.WPA2_PSK})
                if mode==wifi.STATION then
                    wifi.setmode(mode)
                end
                return 204
            elseif kind=="sta" then
                if mode==wifi.SOFTAP then
                    wifi.setmode(wifi.STATIONAP)
                end
                -- XXX: interface differs from wifi.ap.config
                wifi.sta.config(data[1],data[2])
                if mode==wifi.SOFTAP then
                    wifi.setmode(mode)
                end
                return 204
            end
            return 500
        else
            return 400,nil,"[\"ssid\",\"password\"] expected"
        end
    end
    return http_util.make_json_receiver(set_config)(send,data)
end
