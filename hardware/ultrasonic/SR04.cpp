#include "Arduino.h"
#include "SR04.h"

SR04::SR04(int trig, int echo)
{
   pinMode(trig, OUTPUT);
   pinMode(echo, INPUT);
   _trig = trig;
   _echo = echo;
}

long SR04::distance()
{
  digitalWrite(_trig, LOW);
  delayMicroseconds(2);
  digitalWrite(_trig, HIGH);
  delayMicroseconds(10);
  digitalWrite(_trig, LOW);
  return pulseIn(_echo, HIGH) / 51;
}
