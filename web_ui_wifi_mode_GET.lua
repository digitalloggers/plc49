local http_util=require"http_util"

local mode_map={
    [wifi.SOFTAP]="ap",
    [wifi.STATION]="sta",
    [wifi.STATIONAP]="sta+ap"
}

return function(state,send,data)
    return http_util.reply_json(send,mode_map[wifi.getmode()])
end
