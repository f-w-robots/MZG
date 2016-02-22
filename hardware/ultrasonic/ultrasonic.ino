#include "EngineStep.h"
#include "ESP8266Serial.h"
#include "RGBIndication.h"
#include "LineSensor.h"

// ENA, IN1, IN2, IN3, IN4, ENB
Engine engine(6, 7, 5, 4, 2, 3);
EngineStep engineStep(&engine);
// TX, RX
ESP8266Serial esp(8, 9);
//Red, Green, Blue
RGBIndication rgb(11, 12, 13);
// S0, S1, S2, Z
LineSensor line(A3, A4, A5, A2);

String ssid = "robohub";
String password = "robohub1";
String host = "192.168.43.252";
String sha = "car";

String response = "";
int rightSpeed = 0;
int leftSpeed = 0;

boolean lineMode = false;
const uint8_t lineModeSpeed = 70;

int requestTimeout = 0;

// TODO - binary protocol
void parseResponse(String response) {
  boolean left = false;
  boolean right = false;
  int leftSign = 1;
  int rightSign = 1;
  leftSpeed = 0;
  rightSpeed = 0;
  for (int i = 0; i < response.length(); i++) {
    if (response[i] == 'l') {
      right = false;
      left = true;
      if (response[i + 1] == '-')
        leftSign = -1;
    }
    if (response[i] == 'r') {
      left = false;
      right = true;
      if (response[i + 1] == '-')
        rightSign = -1;
    }
    if (response[i] > 47 && response[i] < 58) {
      if (left)
        leftSpeed = leftSpeed * 10 + response[i] - 48;
      if (right)
        rightSpeed = rightSpeed * 10 + response[i] - 48;
    }
  }
  leftSpeed = leftSpeed * leftSign;
  rightSpeed = rightSpeed * rightSign;

  leftSpeed = constrain(leftSpeed, -255, 255);
  rightSpeed = constrain(rightSpeed, -255, 255);
}

void connect() {
  rgb.power();
  delay(500);
  Serial.println("prepare");
  while (!esp.prepare()) {
    Serial.println("try prepare");
    rgb.error();
    delay(500);
    rgb.power();
  }
  rgb.connection();
  delay(300);
  rgb.power();
  Serial.println("connect to wifi");
  while (!esp.upWiFi(ssid, password)) {
    Serial.println("try connect to wifi");
    rgb.error();
    delay(500);
    rgb.power();
  }
  rgb.connection();
  delay(300);
  rgb.power();
  Serial.println("connect to socket");
  while (!esp.connectToSocket(host, "2500", sha)) {
    Serial.println("try connect to socket");
    rgb.error();
  }
}

void setup()
{
  Serial.begin(9600);


  connect();
  rgb.connection();

  Serial.println("connected");
}

void loop()
{
  if (!esp.connected()) {
    rgb.error();
    connect();
    rgb.connection();
    return;
  }
  if (esp.responseAvailable()) {
    response = esp.getResponse();
    Serial.println(response);
    if (response.startsWith("FAIL:")) {
      rgb.error();
      return;
    }
    if (response.startsWith("S")) {
      engineStep.command(response.substring(1));
    }
    if (response.startsWith("T")) {
      parseResponse(response.substring(1));
      engine.rightSpeed(leftSpeed);
      engine.leftSpeed(rightSpeed);
    }
    if (response.startsWith("L1")) {
      lineMode = true;
      engine.rightSpeed(lineModeSpeed);
      engine.leftSpeed(lineModeSpeed);
    }
    if (response.startsWith("L0")) {
      lineMode = false;
      engine.rightSpeed(0);
      engine.leftSpeed(0);
    }
  }
  if (lineMode) {
    int position = line.sensorsPosition() / 2;
    if (position != 0) {
      if (requestTimeout == 0) {
        esp.request("l " + String(lineModeSpeed + position) + " r " + String(lineModeSpeed - position));
      }
      engine.rightSpeed(lineModeSpeed - position);
      engine.leftSpeed(lineModeSpeed + position);
    }

  }
  requestTimeout += 1;
  if (requestTimeout > 15) {
    //    line.readSensors();
    //    String req = line.printSensors();
    //    esp.request(req);
    requestTimeout = 0;
  }
}

