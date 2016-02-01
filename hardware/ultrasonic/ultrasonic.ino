#include "EngineStep.h"
#include "ESP8266Serial.h"
#include "RGBIndication.h"
#include "SR04.h"

// ENA, EN1, EN2, EN3, EN4, ENB
Engine engine(3, 2, 4, 5, 7, 6);
EngineStep engineStep(&engine);
// TX, RX
ESP8266Serial esp(10, 11);
//Red, Green, Blue
RGBIndication rgb(12, 8, 9);
//TRIG, ECHO
SR04 sr04(A0, A1);

boolean connected = false;

String ssid = "ssid";
String password = "password";
String host = "192.168.1.4";
String sha = "car";

String response = "";
int rightSpeed = 0;
int leftSpeed = 0;

int requestTimeout = 0;

boolean connect() {
//  return esp.prepare() && esp.upWiFi(ssid, password) && esp.connectToSocket(host, sha);
  delay(1000);

  if(esp.prepare()) {
    Serial.println("check esp8266 is OK");
    delay(1000);
    if(esp.upWiFi(ssid, password)) {
      Serial.println("connect to wifi is OK");
        delay(1000);
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
  boolean left = false;
  boolean right = false;
  int leftSign = 1;
  int rightSign = 1;
  leftSpeed = 0;
  rightSpeed = 0;
  for(int i = 0; i < response.length(); i++) {
    if(response[i] == 'l') {
      right = false;
      left = true;
      if(response[i+1] == '-') 
        leftSign = -1;
    }
    if(response[i] == 'r') {
      left = false;
      right = true;
      if(response[i+1] == '-') 
        rightSign = -1;
    }
    if(response[i] > 47 && response[i] < 58) {
      if(left)
        leftSpeed = leftSpeed * 10 + response[i] - 48;
      if(right)
        rightSpeed = rightSpeed * 10 + response[i] - 48;
    }
  }
  leftSpeed = leftSpeed * leftSign;
  rightSpeed = rightSpeed * rightSign;

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
    Serial.println(response);
    if(response == "FAIL") {
      rgb.error();
      return;
    }
    if(response.startsWith("S")) {
      engineStep.command(response.substring(1));
    }
    if(response.startsWith("T")) {
      parseResponse(response.substring(1));
      engine.rightSpeed(leftSpeed);
      engine.leftSpeed(rightSpeed);
    }
  }

//  requestTimeout += 1;
//  if(requestTimeout > 100) {
//    esp.request(String(sr04.distance()));
//    requestTimeout = 0;
//  }
  delay(10);
}

