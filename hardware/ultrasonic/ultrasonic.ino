#include "Engine.h"
#include "ESP8266Serial.h"

// ENA, EN1, EN2, EN3, EN4, ENB
Engine engine(3, 2, 4, 5, 7, 6);
// TX, RX
ESP8266Serial esp(10, 11);

boolean connected = false;

String ssid = "ssid";
String password = "password";
String host = "192.168.2.168";
String sha = "car";

boolean connect() {
  return esp.prepare() && esp.upWiFi(ssid, password) && esp.connectToSocket(host, sha);
}

void setup()
{
  Serial.begin(9600);

  while(!connected) {
    connected = connect();
    delay(100);
  }
  Serial.println("connected");

}
void loop()
{
//  engine.rightSpeed(255);
//  engine.leftSpeed(255);
}
