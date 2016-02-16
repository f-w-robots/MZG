#include <SoftwareSerial.h>

#ifndef ESP8266Serial_h
#define ESP8266Serial_h

class ESP8266Serial 
{
  public:
    ESP8266Serial(uint8_t rx, uint8_t tx);
    boolean prepare();
    boolean check();
    boolean upWiFi(String ssid, String password);
    boolean connectToSocket(String host, String port, String sha);
    int status();
    void request(String string);
    String getResponse();
    boolean responseAvailable();
    boolean connected();
  private:
    boolean readString(char b);
    String response();
    boolean responseIsOK(String type);
    
    boolean _espReady;
    boolean _wifi;
    boolean _socket;
    char _buff[255];
    SoftwareSerial* _serial;
    String _string;
    int _connection_timeout;
};

#endif
  
