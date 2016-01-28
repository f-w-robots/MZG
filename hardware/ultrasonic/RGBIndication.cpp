#include "Arduino.h"
#include "RGBIndication.h"

RGBIndication::RGBIndication(uint8_t red, uint8_t green, uint8_t blue)
{
  _red = red;
  _green = green;
  _blue = blue;
}

void RGBIndication::power() {
  digitalWrite(_red, LOW);
  digitalWrite(_green, HIGH);
  digitalWrite(_blue, LOW);
}

void RGBIndication::error() {
  digitalWrite(_red, HIGH);
  digitalWrite(_green, LOW);
  digitalWrite(_blue, LOW);
}

void RGBIndication::connection() {
  digitalWrite(_red, LOW);
  digitalWrite(_green, LOW);
  digitalWrite(_blue, HIGH);
}
