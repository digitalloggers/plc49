local http_util=require"http_util"

return function(state,send,data,kind)
    -- XXX: Working around https://github.com/elua/elua/issues/69
    local ssid,password=wifi[kind].getconfig()
    return http_util.reply_json(send,{ssid,password})
end
