return {
    reply_json=function(send,data)
        send("HTTP/1.0 200 OK\r\nContent-Type: application/json; charset=\"utf-8\"\r\n\r\n")
        send(cjson.encode(data))
    end,
    make_json_receiver=function(callback)
        local accumulator=""
        local content_length
        local function try_parse_json(send,data)
            accumulator=accumulator..data
            if #accumulator==content_length then
                local ok,result=pcall(cjson.decode,accumulator)
                if ok then
                    return callback(send,result)
                else
                    return 400,nil,"Failed to parse JSON: "..result
                end
            elseif #accumulator>content_length then
                return 400,nil,"Request entity larger than expected"
            else
                return nil,try_parse_json
            end
        end
        local function find_data_start(send,data)
            accumulator=accumulator..data
            local header_end,body_pos=accumulator:find("\r\n\r\n.")
            if body_pos then
                local headers=accumulator:sub(1,header_end+2):upper()
                content_length=headers:match("\r\nCONTENT%-LENGTH: *([0-9]*)\r\n")
                content_length=content_length and tonumber(content_length)
                if not content_length then
                    return 411
                else
                    local remainder=accumulator:sub(body_pos)
                    accumulator=""
                    return try_parse_json(send,remainder)
                end
            else
                return nil,find_data_start
            end
        end
        return find_data_start
    end
}
