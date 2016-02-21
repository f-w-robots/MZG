#include "Arduino.h"

#include "LineSensor.h"

LineSensor::LineSensor(uint8_t pin0, uint8_t pin1, uint8_t pin2, uint8_t analog) {
  _pins[0] = pin0;
  pinMode(pin0, OUTPUT);
  _pins[1] = pin1;
  pinMode(pin1, OUTPUT);
  _pins[2] = pin2;
  pinMode(pin2, OUTPUT);
  _analog = analog;

  _cd4051 = new CD4051(pin0, pin1, pin2);
}


String LineSensor::printSensors() {
  String req = "";
  for(int i = 0; i < 6; i++) {
    req += _sensors[i];  
    req += " ";
  }
  return req;
}

void LineSensor::readSensors() {
  for(int i = 0; i < 6; i++) {
    _cd4051->switchInput(i);
    delayMicroseconds(100);
    _sensors[i] = (analogRead(_analog) - _sensorsColibration[i]) * (1023.0/_sensorsColibrationUp[i]);
  }
}

int LineSensor::sensorsPosition() {
  readSensors();
  return correctPath(_sensors[5] > 500, _sensors[2] > 500, _sensors[3] > 500,
    _sensors[1] > 500, _sensors[4] > 500, _sensors[0] > 500);
}

// 1 - stop
// 2 - right
// 3 - left
int LineSensor::correctPath(boolean v0, boolean vc, boolean vr, boolean vl, boolean vr2, boolean vl2) {
//  if(!v0) {
//    return 1;
//  }
//  if(!vc) {
//    return 1;
//  }
  if(!vr && !vc) {
    return 4;
  }
  if(!vl && !vc) {
    return 5;
  }
  if(!vr) {
    return 2;
  }
  if(!vl) {
    return 3;
  }
  
}

