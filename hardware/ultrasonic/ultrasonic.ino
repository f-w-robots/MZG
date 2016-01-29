#include "Engine.h"
#include "ESP8266Serial.h"
#include "RGBIndication.h"

// ENA, EN1, EN2, EN3, EN4, ENB
Engine engine(3, 2, 4, 5, 7, 6);
// TX, RX
ESP8266Serial esp(10, 11);
//Red, Green, Blue
RGBIndication rgb(12, 8, 9);


boolean connected = false;

String ssid = "ssid";
String password = "password";
String host = "192.168.2.168";
String sha = "car";

String response = "";
int rightSpeed = 0;
int leftSpeed = 0;

boolean connect() {
//  return esp.prepare() && esp.upWiFi(ssid, password) && esp.connectToSocket(host, sha);
  delay(1000);

  if(esp.prepare()) {
    Serial.println("check esp8266 is OK");
    if(esp.upWiFi(ssid, password)) {
      Serial.println("connect to wifi is OK");
        if(esp.connectToSocket(host, "2500", sha)) {
          Serial.println("connect to socket is OK");
          return true;
        }
    }
  }
  return false;
}

// TODO - binary protocol
void parseResponse(String response) {
  int left = 0;
  int right = 0;
  leftSpeed = 0;
  rightSpeed = 0;
  for(int i = 0; i < response.length(); i++) {
    if(response[i] == 'l') {
      rightSpeed = rightSpeed * right;
      right = 0;
      if(response[i+1] == '-') 
        left = -1;
      else
        left = 1;
    }
    if(response[i] == 'r') {
      leftSpeed = leftSpeed * left;
      left = 0;
      if(response[i+1] == '-') 
        right = -1;
      else
        right = 1;
    }
    if(response[i] > 47 && response[i] < 58) {
      if(left != 0)
        leftSpeed = leftSpeed * 10 + response[i] - 48;
      if(right != 0)
        rightSpeed = rightSpeed * 10 + response[i] - 48;
    }
  }
  if(abs(leftSpeed) > 0)
    leftSpeed = constrain(leftSpeed, -255, 255);
    rightSpeed = constrain(rightSpeed, -255, 255);
}

void setup()
{
  Serial.begin(9600);
  rgb.power();
  while(!connected) {
    connected = connect();
    if(!connected) {
      Serial.println("unsuccessful");
      rgb.error();
      delay(1000);
    }
  }
  rgb.connection();
  Serial.println("connected");  
}

void loop()
{
  if(!esp.connected()) {
    rgb.error();
    return;
  }
  if(esp.responseAvailable()) {
    response = esp.getResponse();
    Serial.println(response);;
    if(response == "FAIL") {
      rgb.error();
      return;
    }
    parseResponse(response);
    engine.rightSpeed(leftSpeed);
    engine.leftSpeed(rightSpeed);
  }
  delay(1000);
}

