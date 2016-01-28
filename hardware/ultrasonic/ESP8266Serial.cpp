#include "Arduino.h"

#include "ESP8266Serial.h"

ESP8266Serial::ESP8266Serial(uint8_t rx, uint8_t tx) {
  _serial = new SoftwareSerial(rx, tx);
  _serial->begin(9600);
  _buff[0] = 0;
  _connection_timeout = 0;
  _espReady = false;
  _wifi = false;
  _socket = false;
  _string = "";
}

int ESP8266Serial::status() {
  if(!_espReady)
    return 0;
  if(!_wifi)
    return 2;
  if(!_socket)
    return 4;
  return 8;
}

boolean ESP8266Serial::prepare() {
  _serial->println("AT:reset");
  _espReady = responseIsOK();
  return _espReady;
}

boolean ESP8266Serial::upWiFi(String ssid, String password) {  
  if(!_espReady) {
    return false;
  }
  _serial->println("AT:setup+" + ssid + "+" + password);
  _wifi = responseIsOK();
  return _wifi;
}

boolean ESP8266Serial::connectToSocket(String host, String sha) {  
   if(!_wifi) {
    return false;
  }
  _serial->println("AT:connect+" + host + "+" + sha);
  _socket = responseIsOK();
  return _socket;
}

boolean ESP8266Serial::responseIsOK() {
  while(_connection_timeout < 500) {
    _connection_timeout += 1;
    while(_serial->available()>0) {
      if(readString(_serial->read())) {
        _string = String(_buff);
        _buff[0] = 0;
         
        if(_string == "OK") {
          _espReady = true;
          return true;
        } else {
          Serial.println(_string);
          return false;
        }
      }  
    }
    delay(10);
  }
  return false;
}

boolean ESP8266Serial::readString(char b) {
  int len = strlen(_buff);

  if(len >= 255) {
    return true;
  }

  if(b == 0x0A) {
    if(len > 0 && _buff[len - 1] == 0x0D) {
      _buff[len - 1] = 0;
      return true;
    }
  } else {
    _buff[len] = b;
    _buff[len + 1] = 0;
    return false;
  }
}

