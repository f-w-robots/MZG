#include <SoftwareSerial.h>

#ifndef ESP8266Serial_h
#define ESP8266Serial_h

class ESP8266Serial 
{
  public:
    ESP8266Serial(uint8_t rx, uint8_t tx);
    boolean prepare();
    boolean upWiFi(String ssid, String password);
    boolean connectToSocket(String host, String url);
    int status();
    String request(String string);
  private:
    boolean readString(char b);
    String response();
    boolean responseIsOK();
    
    boolean _espReady;
    boolean _wifi;
    boolean _socket;
    char _buff[255];
    SoftwareSerial* _serial;
    String _string;
    int _connection_timeout;
};

#endif
  
