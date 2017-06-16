local mod = {}
-- list of Access points to look at:
mod.SSID = {}  
mod.SSID["hotspot_1"] = "password_here"
mod.SSID["hotspot_2"] = "password_here"
-- MQTT server hostanme and IP:
mod.HOST = "MQTT_BROKER_ADDRESS"  
mod.PORT = 1906  
mod.CERTIFICATE = false 
mod.ID = node.chipid()
-- MQTT topic base path:
mod.ENDPOINT = "portable/nodemcu_01/"  
return mod
