if not file.open(".wifi_configured") then
    file.open(".wifi_configured","w")
    wifi.setmode(wifi.SOFTAP);
    wifi.ap.config({ssid="DLI_PLC49_"..wifi.ap.getmac():gsub(":",""):sub(7):upper(),pwd="plc49dli",auth=wifi.WPA2_PSK});
end
file.close()
wifi.ap.setip({ip="192.168.128.1",netmask="255.255.255.0"});
