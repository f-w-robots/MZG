# MZG
Web Server API

## How to start

#### Installation
##### Server

  - install [docker](https://docs.docker.com/linux/step_one/) and [docker-compose](https://docs.docker.com/compose/install/) for linux, or [docker-toolbox](https://www.docker.com/products/docker-toolbox) for windows/os x
  - ```git clone git@github.com:f-w-robots/MZG.git```
  - ```cd MZG```
  - ```docker-compose build```

##### Hardware
  - Install Arduino IDE 1.6.7+
    - On linux you may  add udev rule, for use IDE whitout root previlgies
  - To work with esp8266, install Arduino core for ESP8266 WiFi chip, [staging branch](https://github.com/esp8266/Arduino#staging-version-)
  - Libraries
    - [ArduinoWebSockets](rduinoWebSockets)(ESP8266)
    - [ArduinoWebsocketClient](https://github.com/f-w-robots/ArduinoWebsocketClient)(WiFiShield)

#### Usage
   - ```docker-compose up```
   - go to http://localhost:4567
   - add new record with id "fake-sha" (without quotes) and code
```
if msg[3] == '2'
  'ls'
elsif msg[0] == '2'
  'fs'
elsif msg[1] == '2'
  'rs'
else
  if msg[3] == '0'
    'l'
  elsif msg[0] == '0'
    'f'
  elsif msg[1] == '0'
    'r'
  else
    'b'
  end
end
```
  - ```docker exec mzg_aserver_1 ruby fake-arduino/arduino.rb fake-sha```
  - for example, restart server ```docker-compose restart aserver```

#### Note
На windows/osx http://localhost:4567 может не работать, нужно посмотреть ip командой ```docker-machine ls```
