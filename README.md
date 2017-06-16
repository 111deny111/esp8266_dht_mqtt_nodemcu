
NodeMcu LUA code to read DHT11/22 temperature and humidity values and send them to MQTT server
What it does is:
- scan WIFI for known access points
- if AP found, connect wifi, connect to MQTT server and start poling DHT sensor and publish temperature and humidity. 
- publish also free ram and uptime, for test purpose
- if deconnected from MQTT, esp8266 reset is done by code
- a LED blink differently depending on the state:
  - no wifi available: fast 5 blink per second
  - AP found: one blink per second
  - connected to AP: one blink every 2 seconds
  - MQTT connected: one blink every 4 seconds


  No TLS at this time, look like the free ram is not enough to handle it. Will try using arduino IDE + c source
  
  
Lavaux Gilles 2017/05

