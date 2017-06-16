local module = {} 

local m = nil
local oldSec = -1
local newSec = -1
local uptime = nil
local uptimeLoop = 0
local timeLimit = 0

-- dht11 reading
local PIN=2 --DHT data pin, GPIO4
local humi=0
local temp=0
-- leds
local L0PIN=3 --LED0 data pin, GPIO0
local L0S = gpio.LOW
L0D = 50 -- blink duration
gpio.mode(L0PIN, gpio.OUTPUT)
gpio.write(L0PIN, L0S)

function module.setBlinkPeriod(p)
    print("set blink to:"..p)
    tmr.interval(4, p)
end

function blink()
    if L0S == gpio.LOW then
        L0S = gpio.HIGH
    else
        L0S = gpio.LOW
    end
    gpio.write(L0PIN, L0S)
end 

tmr.alarm(4, L0D, 1, blink)

function readDHT()
    status,temp,humi,temp_dec,humi_dec=dht.read(PIN)
    if status==dht.OK then
        print( " DHT temp:"..temp.."; humidity:"..humi)
    elseif status==dht.ERROR_CHECKSUM then
        print( " DHT Checksum error." )
    elseif status==dht.ERROR_TIMEOUT then
        print( " DHT timed out." )
    end
end

local function getUptime()
    newSec = tmr.time()/60
    if newSec < oldSec then
        -- counter has looped
        timeLimit = oldSec
        print("## tmr.time has looped at:" .. timeLimit)
        uptimeLoop = uptimeLoop + 1
    end
    uptime = uptimeLoop .. "_" .. timeLimit .. "_" .. newSec
    print(" uptime:" .. uptime)
    oldSec=newSec
end

-- Sends a simple ping to the broker
local function send_ping()
    getUptime()
    readDHT()
    m:publish(config.ENDPOINT .. config.ID .. "/humi", humi ,0, 0)
    m:publish(config.ENDPOINT .. config.ID .. "/temp", temp ,0, 0)
    m:publish(config.ENDPOINT .. config.ID .. "/uptime", newSec ,0, 0)
    m:publish(config.ENDPOINT .. config.ID .. "/mem", collectgarbage("count")*1024 ,0, 0)
    print(" ping sent(sec="..newSec..",mem="..(collectgarbage("count")*1024)..",temp="..temp..",humi="..humi..")...")
end


-- Sends my id to the broker for registration
local function register_myself()  
    m:subscribe(config.ENDPOINT .. config.ID,0,function(conn)
        print(" successfully subscribed to data endpoint")
    end)
end

local function mqtt_start()  
    m = mqtt.Client(config.ID, 120)
    -- register message callback beforehand
    m:on("message", function(conn, topic, data) 
      if data ~= nil then
        print(" message: " .. topic .. ": " .. data)
        -- do something, we have received a message
      end
    end)
    -- disconnected
    m:on("offline", function(con)
        print (" offline !!")
        module.setBlinkPeriod(2000)
        node.restart()
    end)
    -- Connect to broker
    m:connect(config.HOST, config.PORT, 0, 0, function(con) 
        register_myself()
        -- And then pings each 10000 milliseconds
        module.setBlinkPeriod(4000)
        tmr.stop(6)
        tmr.alarm(6, 10000, 1, send_ping)
    end) 

end


function module.start()
  module.setBlinkPeriod(2000)
  setup = nil -- GL: save mem? 
  mqtt_start()
end

return module  
