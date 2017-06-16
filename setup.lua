local mod = {}

local Apfound = 0

function wifi_wait_ip()  
  if wifi.sta.getip()== nil then
    print(" IP unavailable, Waiting...")
  else
    tmr.stop(2)
    print("\n==============================")
    print("ESP8266 mode: " .. wifi.getmode())
    print("MAC address: " .. wifi.ap.getmac())
    print("IP: ".. wifi.sta.getip())
    print("==============================")
    app.start()
  end
end

function wifi_start(list_aps)
    if list_aps then
        for key,value in pairs(list_aps) do
            print(" testing AP '" .. key .. "':'" .. value .. "'")
            if config.SSID and config.SSID[key] then
                print(" using AP '" .. key .. "':'" .. value .. "'")
                app.setBlinkPeriod(1000)
                wifi.setmode(wifi.STATION);
                wifi.sta.config(key,config.SSID[key])
                wifi.sta.connect()
                print(" connecting to " .. key .. "...")
                Apfound = 1
                tmr.alarm(2, 2500, 1, wifi_wait_ip)
                break
            end
        end
        if (Apfound == 0) then
            print(" configured AP not found !")
            tmr.alarm(3, 5000, 0, function()
                scanAp(2)
            end)
            print("  will retry in 5 secs")
        else
            print(" configured AP found")
        end
    else
        print(" error getting AP list")
        tmr.alarm(3, 6000, 0 , function()
            scanAp(3)
        end)
        print("  will retry in 6 secs")
    end
end

function scanAp(num)
    app.setBlinkPeriod(200)
    print("\nScan AP " .. num .. " (" .. collectgarbage("count")*1024 .. ")...")
    wifi.sta.getap(wifi_start)
end

function mod.start()
  wifi.setmode(wifi.STATION)
  print("\nConfiguring Wifi ...")
  scanAp(0)
end

return mod
