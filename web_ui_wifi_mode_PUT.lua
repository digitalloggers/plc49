local http_util=require"http_util"

local mode_map={
    ["ap"]=wifi.SOFTAP,
    ["sta"]=wifi.STATION,
    ["sta+ap"]=wifi.STATIONAP
}

return function(state,send,data)
    local acc=""
    local function set_mode(send,mode)
        mode=mode_map[mode]
        if mode then
            wifi.setmode(mode)
            return 204
        else
            return 400,nil,"\"ap\",\"sta\" or \"sta+ap\" expected"
        end
    end
    return http_util.make_json_receiver(set_mode)(send,data)
end
