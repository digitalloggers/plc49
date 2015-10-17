local require_once=require"require_once"

local http_status={
    [204]="No content",
    [400]="Bad request",
    [404]="Not found",
    [405]="Method not supported",
    [411]="Length required",
    [500]="Internal server error"
}

local CLIENT_LIMIT=2
local SEND_SIZE=1400

return function(routing)
    local ret=net.createServer(net.TCP, 30)
    local state={}
    local client_count=0
    local throttle_seconds=0
    ret:listen(
        80,
        function(c)
            local recv_state=false
            local send_state=false
            local latest_error
            local send_busy
            local send_buf=""
            local function send(str)
                send_buf=send_buf..str
            end
            if client_count+1>CLIENT_LIMIT then
                throttle_seconds=throttle_seconds+1
                c:send(string.format("HTTP/1.0 503 Service Unavailable\r\nRetry-After: %d\r\n\r\n",math.floor(throttle_seconds)))
                c:close()
                return
            end
            client_count=client_count+1
            local function handle_pcall(ok,new_send_state_or_err,new_recv_state,new_latest_error)
                if ok then
                    send_state,recv_state,latest_error=new_send_state_or_err,new_recv_state,new_latest_error
                else
                    latest_error=new_send_state_or_err
                    send_state=500
                    recv_state=nil
                end
                return ok
            end
            local function state_postprocess(s)
                if type(send_state)=="number" then
                    -- TODO: Technically we can be in the middle
                    -- of output, so this string won't have any
                    -- effect. It could still be useful for
                    -- diagnostics.
                    local status_message, content_type, content
                    if send_state==204 then
                        status_message=latest_error
                    end
                    status_message=status_message or http_status[send_state] or "Status"
                    if send_state~=204 and latest_error~=false then
                        content_type="Content-Type: text/plain; charset=\"utf-8\"\r\n"
                        content=latest_error or http_status[send_state]
                    end
                    send(string.format("HTTP/1.0 %d %s\r\n%s\r\n%s",send_state,status_message,content_type or "", content or ""))
                    send_state=nil
                end
                if not send_busy and send_buf~="" then
                    s:send(send_buf:sub(1,SEND_SIZE))
                    send_busy=true
                    send_buf=send_buf:sub(SEND_SIZE+1)
                end
                if not send_busy and recv_state==nil and send_state==nil then
                    s:close()
                end
            end
            c:on("sent",
                 function(s)
                     if send_buf=="" then
                         send_busy=false
                         if send_state then
                             handle_pcall(pcall(send_state,send))
                         end
                         state_postprocess(s)
                     else
                         s:send(send_buf:sub(1,SEND_SIZE))
                         send_buf=send_buf:sub(SEND_SIZE+1)
                     end
                 end
            )
            c:on("receive",
                 function(s,data)
                     if recv_state==false then
                         local handler,arguments=require_once(routing)(state,data)
                         if type(handler)=="string" then
                             local ok
                             ok,handler=pcall(require_once,handler)
                             if ok then
                                 handle_pcall(pcall(handler,state,send,data,unpack(arguments)))
                             else
                                 recv_state=nil
                                 send_state=500
                                 latest_error=handler
                             end
                         else
                             recv_state=nil
                             send_state,latest_error=handler,arguments
                         end
                     elseif recv_state~=nil then
                         handle_pcall(pcall(recv_state,send,data))
                     end
                     state_postprocess(s)
                 end
            )
            c:on("disconnection",
                 function(s)
                     client_count=client_count-1
                     throttle_seconds=throttle_seconds/2
                 end
            )
        end
    )
    return function()
        ret:close()
    end
end
