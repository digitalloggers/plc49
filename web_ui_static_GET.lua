local mimetypes={
    ["html"] = "text/html; charset=\"utf-8\"",
    ["xml"] = "text/xml; charset=\"utf-8\"",
    ["txt"] = "text/plain; charset=\"utf-8\"",
    ["png"] = "image/png",
    ["ico"] = "image/x-icon",
    ["css"] = "text/css; charset=\"utf-8\"",
    ["js"] = "text/javascript; charset=\"utf-8\""
}

return function(state,s,data,staticroot,url)
    local curfile
    local curpos=0
    local found
    if url:sub(#url)=="/" then
        url=url.."index.html"
    end
    if file.open(staticroot..url) then
        file.close()
        curfile=staticroot..url
        found=true
    elseif file.open(staticroot..url..".gz") then
        file.close()
        curfile=staticroot..url..".gz"
        found="gzip"
    end
    if found then
        s:send("HTTP/1.0 200 OK\r\n")
        local ext=url:match(".*%.(%w*)")
        if found=="gzip" then
            s:send("Content-Encoding: gzip\r\n")
        end
        s:send("Content-Type: "..(mimetypes[ext] or "application/octet-stream").."\r\n\r\n")
        local function sendfile(s)
            file.open(curfile)
            file.seek("set",curpos)
            local data=file.read()
            if data then
                curpos=curpos+#data
                s:send(data)
            end
            file.close()
            return data and sendfile
        end
        return sendfile
    else
        return 404
    end
end
