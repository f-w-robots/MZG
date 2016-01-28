#include "Engine.h"
#include "ESP8266Serial.h"

// ENA, EN1, EN2, EN3, EN4, ENB
Engine engine(3, 2, 4, 5, 7, 6);
// TX, RX
ESP8266Serial esp(10, 11);

boolean connected = false;

boolean connect() {
  return esp.prepare() && esp.upWiFi("ssid", "password") && esp.connectToSocket("192.168.2.168", "sha1");
}

void setup()
{
  Serial.begin(9600);

  if(connected = connect()) {
    Serial.println("connected");
  } else {
    Serial.println("not connected");
  }
}
void loop()
{
//  engine.rightSpeed(255);
//  engine.leftSpeed(255);
}
