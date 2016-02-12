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
    - [ArduinoWebSockets](https://github.com/Links2004/arduinoWebSockets)(ESP8266)
    - [ArduinoWebsocketClient](https://github.com/f-w-robots/ArduinoWebsocketClient)(WiFiShield)

#### Usage
  - ```docker-compose up```
  - go to http://localhost:4567
  - add new record with id "fake-sha" (without quotes) and code
  - select Algorithm and copy code from comments in file fake-arduino/labirint.rb into textarea
  - ```docker exec -it mzg_hwserver_1 ruby fake-arduino/arduino.rb fake-sha```

#### Note
On windows/osx instead http://localhost:4567 you must use http://\<docker-machine ip\>:4567, ip shows by ```docker-machine ls```
