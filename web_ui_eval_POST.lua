local http_util=require"http_util"

return function(state,send,data)
    local eval_vars=state.eval_vars
    if not eval_vars then
        eval_vars={}
        state.eval_vars=eval_vars
    end
    local function run_acc(send,acc)
        if type(acc)~="string" then
            return 400,nil,"String to execute expected"
        end
        -- XXX: We do piecewise JSON output here, something not supported by cjson
        send("HTTP/1.0 200 OK\r\nContent-Type: application/json; charset=\"utf-8\"\r\n\r\n")
        send("[")
        local maybe_comma=""
        local status
        if acc:sub(1,1)=="=" then
            acc="print("..acc:sub(2)..")"
        end
        local fn,err=loadstring(acc,"web input")
        if fn then
            local function print_sock(...)
                local output=""
                local args={...}
                local n=select("#",...)
                for i=1,n do
                    if i>0 then
                        output=output..tostring(args[i])..(i==n and "\n" or "\t")
                    end
                end
                send(string.format("%s[%q,%s]",maybe_comma,"print",cjson.encode(output)))
                maybe_comma=","
            end
            setfenv(fn,
                    setmetatable(
                        {},
                        {
                            __index=function(tbl,key)
                                if key=="print" then
                                    return print_sock
                                elseif eval_vars[key]~=nil then
                                    return eval_vars[key]
                                else
                                    return _G[key]
                                end
                            end,
                            __newindex=function(tbl,key,value)
                                if key~="print" then
                                    eval_vars[key]=value
                                end
                            end
                        }
            ))
            local ok
            ok,err=pcall(fn)
            if not ok then
                send(string.format("%s[%q,%s]",maybe_comma,"run-error",cjson.encode(err or "")))
                maybe_comma=","
            end
        else
            send(string.format("%s[%q,%s]",maybe_comma,"parse-error",cjson.encode(err or "")))
            maybe_comma=","
        end
        send(string.format("%s[%q,%d]",maybe_comma,"heap",node.heap()))
        maybe_comma=","
        send("]")
    end
    return http_util.make_json_receiver(run_acc)(send,data)
end
